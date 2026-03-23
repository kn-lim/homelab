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

  values = {
    name = values.name
  }
}

unit "onepassword-secret-write" {
  source = "${find_in_parent_folders("_units/onepassword-secret-write")}"

  path = "onepassword-secret-write"

  values = {
    vault_name  = values.vault_name
    secret_name = "webhook"
  }
}

unit "lambda" {
  source = "${find_in_parent_folders("_units/aws/lambda")}"

  path = "lambda"

  values = {
    name = values.name

    s3_bucket = values.s3_bucket
    s3_key    = values.s3_key
  }
}

unit "apigateway" {
  source = "${find_in_parent_folders("_units/aws/apigateway")}"

  path = "apigateway"

  values = {
    name = values.name
  }
}

unit "lambda-permission" {
  source = "${find_in_parent_folders("_units/aws/lambda-permission")}"

  path = "lambda-permission"

  values = {
    name = values.name
  }
}
