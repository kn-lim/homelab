unit "onepassword-secret-read" {
  source = "${find_in_parent_folders("_units/onepassword-secret-read")}"

  path = "onepassword-secret-read"

  values = {
    vault_name  = values.vault_name
    secret_name = values.secret_name
  }
}

unit "sqs" {
  source = "${find_in_parent_folders("_units/aws/sqs")}"

  path = "sqs"

  values = {
    name = values.name
  }
}

unit "iam-user" {
  source = "${find_in_parent_folders("_units/aws/iam-user")}"

  path = "iam-user"

  autoinclude {
    dependency "sqs" {
      config_path = unit.sqs.path

      mock_outputs = {
        queue_arn = "arn:aws:sqs:us-west-2:123456789012:mock-queue"
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      inline_policy_permissions = {
        sqs = {
          actions   = ["sqs:GetQueueUrl", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
          resources = [dependency.sqs.outputs.queue_arn]
        }
      }
    }
  }

  values = {
    name = values.name
  }
}

unit "onepassword-secret-write" {
  source = "${find_in_parent_folders("_units/onepassword-secret-write")}"

  path = "onepassword-secret-write"

  autoinclude {
    dependency "sqs" {
      config_path = unit.sqs.path

      mock_outputs = {
        queue_url = "https://sqs.us-west-2.amazonaws.com/123456789012/mock-queue"
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    dependency "iam-user" {
      config_path = unit.iam-user.path

      mock_outputs = {
        access_key_id     = "mock-access-key-id"
        access_key_secret = "mock-secret-access-key"
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      fields = {
        sqs_url               = dependency.sqs.outputs.queue_url
        aws_access_key_id     = dependency.iam-user.outputs.access_key_id
        aws_secret_access_key = dependency.iam-user.outputs.access_key_secret
      }
    }
  }

  values = {
    vault_name  = values.vault_name
    secret_name = "webhook"
  }
}

unit "lambda" {
  source = "${find_in_parent_folders("_units/aws/lambda")}"

  path = "lambda"

  autoinclude {
    dependency "onepassword-secret-read" {
      config_path = unit.onepassword-secret-read.path

      mock_outputs = {
        fields = {
          credential = "mock-credential"
        }
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    dependency "sqs" {
      config_path = unit.sqs.path

      mock_outputs = {
        queue_arn = "arn:aws:sqs:us-west-2:123456789012:mock-queue"
        queue_url = "https://sqs.us-west-2.amazonaws.com/123456789012/mock-queue"
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      environment_variables = {
        AWS_SQS_URL = dependency.sqs.outputs.queue_url
        # TODO: Replace with custom label when possible
        GITHUB_WEBHOOK_SECRET = dependency.onepassword-secret-read.outputs.fields["credential"]
      }

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
    }
  }

  values = {
    name = values.name

    s3_bucket = values.s3_bucket
    s3_key    = values.s3_key
  }
}

unit "apigateway" {
  source = "${find_in_parent_folders("_units/aws/apigateway")}"

  path = "apigateway"

  autoinclude {
    dependency "lambda" {
      config_path = unit.lambda.path

      mock_outputs = {
        lambda_function_invoke_arn = "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:123456789012:function:mock-lambda/invocations"
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      routes = {
        "POST /" = {
          integration = {
            uri                    = dependency.lambda.outputs.lambda_function_invoke_arn
            payload_format_version = "2.0"
          }
        }
      }
    }
  }

  values = {
    name = values.name
  }
}

unit "lambda-permission" {
  source = "${find_in_parent_folders("_units/aws/lambda-permission")}"

  path = "lambda-permission"

  autoinclude {
    dependency "lambda" {
      config_path = unit.lambda.path

      mock_outputs = {
        lambda_function_name = "mock-lambda"
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    dependency "apigateway" {
      config_path = unit.apigateway.path

      mock_outputs = {
        api_execution_arn = "arn:aws:execute-api:us-west-2:123456789012:abcdef1234"
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      function_name     = dependency.lambda.outputs.lambda_function_name
      api_execution_arn = dependency.apigateway.outputs.api_execution_arn
    }
  }
}
