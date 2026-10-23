terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0, < 8.0"
    }
  }
}

variable "project_id" {
  description = "Project that hosts the bastion."
  type        = string
}

variable "network_name" {
  description = "Name of an existing VPC network."
  type        = string
}

variable "subnet_name" {
  description = "Name of an existing subnet in us-central1."
  type        = string
}

variable "member" {
  description = "IAM member allowed to connect, for example user:alice@example.com."
  type        = string
}

module "this" {
  source = "../../"

  name       = "example"
  project_id = var.project_id
  zone       = "us-central1-a"
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }

  network = {
    name        = var.network_name
    subnet_name = var.subnet_name
  }
  members = [var.member]
}

output "instance_name" {
  description = "Name of the bastion."
  value       = module.this.name
}
