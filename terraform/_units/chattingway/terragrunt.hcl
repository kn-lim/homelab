locals {
  tags = {
    app = values.name
  }
}

inputs = {
  s3_bucket       = get_env("TG_BUCKET", "")
  endpoint_s3_key = "lambda/${values.name}/endpoint/bootstrap.zip"
  task_s3_key     = "lambda/${values.name}/task/bootstrap.zip"

  name = values.name
  # log_format = "JSON"
  # retention_in_days = 3
  # runtime = "provided.al2023"
  # endpoint_timeout = 3
  # task_timeout = 300
  # ec2_instance_arns = []
  tags = local.tags
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # https://github.com/kn-lim/terraform-aws-chattingway
  source = "git::https://github.com/kn-lim/terraform-aws-chattingway.git//?ref=v2.3.0"
}
