locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
}

dependency "onepassword_secret" {
  config_path = "../onepassword-secret"
}

dependency "sqs" {
  config_path = "../sqs"
}

inputs = {
  function_name = "${values.name}-lambda"
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["arm64"]
  timeout       = 30

  create_package          = false
  ignore_source_code_hash = true

  s3_existing_package = {
    bucket = values.s3_bucket
    key    = values.s3_key
  }

  environment_variables = {
    GITHUB_WEBHOOK_SECRET = dependency.onepassword_secret.outputs.fields["webhook_secret"]
    AWS_SQS_URL           = dependency.sqs.outputs.queue_url
  }

  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = dependency.sqs.outputs.queue_arn
      }
    ]
  })

  cloudwatch_logs_retention_in_days = 30
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/lambda/aws?version=8.7.0"
}
