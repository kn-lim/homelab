terragrunt_version_constraint = ">= 1.2"

locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = try(read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region, "")
  unit     = read_terragrunt_config("${get_terragrunt_dir()}/unit.hcl").locals.unit

  # Backend configuration
  backend_bucket = "${get_env("TF_BUCKET", "")}"
  backend_region = "${get_env("AWS_REGION", "us-west-2")}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOT
%{if local.platform == "aws"}
provider "aws" {
  default_tags {
    tags = {
      path   = "${get_path_from_repo_root()}"
      repo   = "homelab"
      source = "terraform"
    }
  }

  region = "${local.region}"
}
%{endif}

%{if startswith(local.unit, "grafana-")}
provider "grafana" {}
%{endif}

%{if startswith(local.unit, "onepassword-")}
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
