output "id" {
  description = "Instance ID (projects/<project>/zones/<zone>/instances/<name>). Null when create is false."
  value       = var.create ? "projects/${var.project_id}/zones/${var.zone}/instances/${var.name}" : null
}

output "name" {
  description = "Instance host name. Null when create is false."
  value       = var.create ? module.this[0].hostname : null
}

output "self_link" {
  description = "Self link of the bastion instance. Null when create is false."
  value       = var.create ? module.this[0].self_link : null
}

output "ip_address" {
  description = "Internal IP address of the bastion. Null when create is false."
  value       = var.create ? module.this[0].ip_address : null
}

output "service_account_email" {
  description = "Email of the service account the bastion runs as. Null when create is false."
  value       = var.create ? module.this[0].service_account : null
}

output "labels" {
  description = "Labels applied to the bastion, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.labels : null
}

output "external_ip_enabled" {
  description = "Whether the bastion has an external IP. Always false; null when create is false."
  value       = var.create ? false : null
}

output "members" {
  description = "IAM members granted IAP tunnel and OS Login access. Null when create is false."
  value       = var.create ? var.members : null
}
