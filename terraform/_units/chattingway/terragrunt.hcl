locals {
  tags = {
    app = values.name
  }

  endpoint_filename = "./endpoint/bootstrap.zip"
  task_filename     = "./task/bootstrap.zip"
}

inputs = {
  endpoint_filename = local.endpoint_filename
  task_filename     = local.task_filename

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
  source = "git::https://github.com/kn-lim/terraform-aws-chattingway.git//?ref=main"
}
