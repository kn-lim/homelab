variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "api_execution_arn" {
  description = "Execution ARN of the API Gateway (e.g. arn:aws:execute-api:region:account:api-id)"
  type        = string
}
