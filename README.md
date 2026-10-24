# terraform-google-bastion-host

Bastion VM with no external IP, IAP-only SSH, OS Login and shielded VM, for named members

## Opinions

- No external IP: `external_ip = false`; the only way in is an IAP TCP tunnel.
- IAP-only SSH: a firewall rule allows tcp/22 from the IAP range `35.235.240.0/20` to the bastion's service account.
- OS Login is enabled (`enable-oslogin = "TRUE"`); each member gets `roles/iap.tunnelResourceAccessor` (upstream) and `roles/compute.osLogin` on the instance (this module).
- Shielded VM on, Debian 12 (`debian-12` from `debian-cloud`), 10 GB boot disk, `e2-micro` by default.
- Service account roles are upstream's defaults (log writer, metric writer, monitoring viewer, OS Login project get); none are added.
- Resource names (service account, template, firewall rule) derive from `name`, so several bastions can share a project.
- The upstream instance template submodule (terraform-google-modules/vm 13.x) creates the template with `google-beta` (`>= 5.36, < 8`); this module declares `google-beta` as `>= 6.0, < 8.0`. Configure both `google` and `google-beta` in the root module (same project and credentials).
- `context.extra_tags` keys and values are normalised to valid GCP label syntax (lowercase, `[^a-z0-9_-]` → `-`, 63 chars); `labels` are applied verbatim and win.

## Usage

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "this" {
  source = "git::https://github.com/Olensys/terraform-google-bastion-host.git?ref=v1.1.0"

  name       = module.naming.name
  project_id = "example-project"
  zone       = "us-central1-a"
  context = {
    organization = "olensys"
    environment  = "dev"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }

  network = {
    name        = "example-net"
    subnet_name = "example-subnet"
  }
  members = ["user:alice@example.com"]

  labels = module.naming.labels
}
```

Connect through IAP:

```bash
gcloud compute ssh example --zone us-central1-a --project example-project --tunnel-through-iap
```

The subnet must be in the region of `zone`; Private Google Access or a NAT is needed only if the VM must reach the internet.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 6.0, < 8.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5, < 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.0, < 8.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this"></a> [this](#module\_this) | terraform-google-modules/bastion-host/google | 9.0.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_instance_iam_member.os_login](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_members"></a> [members](#input\_members) | IAM members allowed to reach the bastion through IAP and sign in with OS Login, each prefixed user:, group:, serviceAccount: or domain:. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Instance name. Starts with a lowercase letter; lowercase letters, digits and hyphens; at most 22 characters so the derived service account id (<name>-bastion) stays within 30. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Existing VPC network and subnet (names, in project\_id and in the region of zone) the bastion attaches to. | <pre>object({<br/>    name        = string<br/>    subnet_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project that hosts the bastion VM and its network. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone for the bastion VM, for example us-central1-a. The region is derived from it. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels merged onto every labelable resource, applied last. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type of the bastion VM. | `string` | `"e2-micro"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_external_ip_enabled"></a> [external\_ip\_enabled](#output\_external\_ip\_enabled) | Whether the bastion has an external IP. Always false; null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Instance ID (projects/<project>/zones/<zone>/instances/<name>). Null when create is false. |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | Internal IP address of the bastion. Null when create is false. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels applied to the bastion, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_members"></a> [members](#output\_members) | IAM members granted IAP tunnel and OS Login access. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Instance host name. Null when create is false. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Self link of the bastion instance. Null when create is false. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the service account the bastion runs as. Null when create is false. |
<!-- END_TF_DOCS -->
