terragrunt_version_constraint = ">= 0.99.0"

locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
  unit     = read_terragrunt_config("${get_terragrunt_dir()}/unit.hcl").locals.unit

  # Backend configuration
  backend_bucket = "${get_env("TG_BUCKET", "")}"
  backend_region = "us-west-2"

  # Kubernetes
  kubeconfig_path = "${get_repo_root()}/${local.platform}-${local.region}.kubeconfig"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOT
%{if local.unit == "cluster-bootstrap"}
provider "kubernetes" {
  config_path = "${local.kubeconfig_path}"
}
%{endif}

%{if local.unit == "grafana"}
provider "grafana" {}
%{endif}

%{if local.unit == "onepassword-secret"}
provider "onepassword" {}
%{endif}

%{if local.unit == "talos"}
provider "talos" {}
%{endif}
EOT
}

remote_state {
  backend = "s3"
  config = {
    bucket  = local.backend_bucket
    encrypt = true
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.backend_region
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
