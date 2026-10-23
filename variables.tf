variable "name" {
  description = "Resource name. Lowercase letters, digits and hyphens."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.name))
    error_message = "name must match ^[a-z0-9-]{1,63}$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "project_id" {
  description = "Project that hosts the bastion VM and its network."
  type        = string
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "zone" {
  description = "Zone for the bastion VM, for example us-central1-a. The region is derived from it."
  type        = string
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]$", var.zone))
    error_message = "zone must look like us-central1-a."
  }
}

variable "network" {
  description = "Existing VPC network and subnet (names, in project_id and in the region of zone) the bastion attaches to."
  type = object({
    name        = string
    subnet_name = string
  })
}

variable "members" {
  description = "IAM members allowed to reach the bastion through IAP and sign in with OS Login, each prefixed user:, group:, serviceAccount: or domain:."
  type        = list(string)
  validation {
    condition     = length(var.members) > 0 && alltrue([for m in var.members : can(regex("^(user|group|serviceAccount|domain):.+$", m))])
    error_message = "members must be a non-empty list of strings prefixed user:, group:, serviceAccount: or domain:."
  }
}

variable "machine_type" {
  description = "Machine type of the bastion VM."
  type        = string
  default     = "e2-micro"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.machine_type))
    error_message = "machine_type must contain only lowercase letters, digits and hyphens."
  }
}

variable "labels" {
  description = "Labels merged onto every labelable resource, applied last."
  type        = map(string)
  default     = {}
}
