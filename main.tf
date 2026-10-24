locals {
  extra_labels = { for k, v in var.context.extra_tags :
  substr(replace(lower(k), "/[^a-z0-9_-]/", "-"), 0, 63) => substr(replace(lower(v), "/[^a-z0-9_-]/", "-"), 0, 63) }
  labels = merge(local.extra_labels, var.labels)

  region = join("-", slice(split("-", var.zone), 0, 2))

  # Names derived from var.name so several bastions in one project never collide.
  service_account_name = trim(substr("${var.name}-bastion", 0, 30), "-")
  template_prefix      = trim(substr(var.name, 0, 40), "-")
  firewall_name        = "${trim(substr(var.name, 0, 40), "-")}-allow-iap-ssh"
}

module "this" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "9.0.0"

  count = var.create ? 1 : 0

  project = var.project_id
  zone    = var.zone
  region  = local.region
  name    = var.name
  network = "projects/${var.project_id}/global/networks/${var.network.name}"
  subnet  = "projects/${var.project_id}/regions/${local.region}/subnetworks/${var.network.subnet_name}"

  machine_type = var.machine_type
  members      = var.members

  # No public address; access is IAP tunnelling only.
  external_ip          = false
  create_firewall_rule = true

  shielded_vm  = true
  image_family = "debian-12"
  # Pinned explicitly: the image project that serves the family.
  image_project = "debian-cloud"
  disk_size_gb  = 10

  # OS Login is always enabled by upstream; stated here so the opinion is explicit.
  metadata = { enable-oslogin = "TRUE" }

  service_account_name       = local.service_account_name
  name_prefix                = "${local.template_prefix}-tpl"
  fw_name_allow_ssh_from_iap = local.firewall_name

  labels = local.labels
}

# Members need OS Login rights on the instance to sign in over the tunnel.
resource "google_compute_instance_iam_member" "os_login" {
  for_each = var.create ? toset(var.members) : toset([])

  project       = var.project_id
  zone          = var.zone
  instance_name = var.name
  role          = "roles/compute.osLogin"
  member        = each.value

  depends_on = [module.this]
}
