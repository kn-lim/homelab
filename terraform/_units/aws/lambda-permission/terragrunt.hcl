dependency "lambda" {
  config_path = "../lambda"
}

dependency "apigateway" {
  config_path = "../apigateway"
}

inputs = {
  function_name     = dependency.lambda.outputs.lambda_function_name
  api_execution_arn = dependency.apigateway.outputs.api_execution_arn
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/aws/lambda-permission")}"
}
