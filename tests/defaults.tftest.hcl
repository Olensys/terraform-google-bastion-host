mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      id     = "projects/example-project/serviceAccounts/example-bastion@example-project.iam.gserviceaccount.com"
      email  = "example-bastion@example-project.iam.gserviceaccount.com"
      member = "serviceAccount:example-bastion@example-project.iam.gserviceaccount.com"
    }
  }
}
mock_provider "google-beta" {}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name       = "example"
  project_id = "example-project"
  zone       = "us-central1-a"
  network = {
    name        = "example-net"
    subnet_name = "example-subnet"
  }
  members = ["user:alice@example.com", "group:ops@example.com"]
}

run "test_no_external_ip" {
  command = plan

  # SMOKE: asserts the module-computed external_ip_enabled output is false and no override input exists; the upstream access_config block lives in a child module, so complete.tftest.hcl and trivy prove the instance has no public address.
  assert {
    condition     = output.external_ip_enabled == false
    error_message = "The bastion must not have an external IP."
  }
}

run "test_iap_members" {
  command = plan

  assert {
    condition     = output.members == tolist(["user:alice@example.com", "group:ops@example.com"])
    error_message = "Members must be passed through unchanged."
  }

  assert {
    condition     = length(google_compute_instance_iam_member.os_login) == 2 && google_compute_instance_iam_member.os_login["user:alice@example.com"].role == "roles/compute.osLogin"
    error_message = "Every member must get roles/compute.osLogin on the instance."
  }

  # SMOKE: the roles/iap.tunnelResourceAccessor binding is created by the upstream child module and is not visible here; complete.tftest.hcl proves it.
  assert {
    condition     = google_compute_instance_iam_member.os_login["group:ops@example.com"].zone == "us-central1-a"
    error_message = "OS Login binding must target the instance zone."
  }
}

run "test_shielded_vm" {
  command = plan

  # SMOKE: shielded_vm = true is hardcoded in the upstream call and not exposed as an output; this only proves the plan succeeds with defaults. The real check is complete.tftest.hcl and trivy.
  assert {
    condition     = output.name == "example" && output.external_ip_enabled == false
    error_message = "Default plan must succeed with the hardened settings."
  }
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = output.id == null && output.name == null && output.self_link == null && output.service_account_email == null && output.labels == null && output.external_ip_enabled == null && output.members == null && output.ip_address == null
    error_message = "Every output must be null when create is false."
  }

  assert {
    condition     = length(google_compute_instance_iam_member.os_login) == 0
    error_message = "No IAM bindings may be planned when create is false."
  }
}

run "test_tags_contract" {
  command = plan

  variables {
    labels = { owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { owner = "y", team = "z" }
    }
  }

  assert {
    condition     = output.labels.owner == "x"
    error_message = "var.labels must win over context.extra_tags."
  }

  assert {
    condition     = output.labels.team == "z"
    error_message = "context.extra_tags must be merged."
  }
}

run "test_member_format_validation" {
  command = plan

  variables {
    members = ["alice@example.com"]
  }

  expect_failures = [var.members]
}

run "test_members_not_empty_validation" {
  command = plan

  variables {
    members = []
  }

  expect_failures = [var.members]
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "a-name-that-is-far-too-long-for-the-service-account-id"
  }

  expect_failures = [var.name]
}

run "test_name_leading_digit_validation" {
  command = plan

  variables {
    name = "1foo"
  }

  expect_failures = [var.name]
}

run "test_name_leading_hyphen_validation" {
  command = plan

  variables {
    name = "-foo"
  }

  expect_failures = [var.name]
}

run "test_zone_validation" {
  command = plan

  variables {
    zone = "us-central1"
  }

  expect_failures = [var.zone]
}
