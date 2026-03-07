unit "onepassword-secret" {
  source = "${find_in_parent_folders("_units/onepassword-secret")}"

  path = "onepassword-secret"

  values = {
    vault_name  = "Homelab"
    secret_name = "github"
  }
}

unit "sqs" {
  source = "${find_in_parent_folders("_units/aws/sqs")}"

  path = "sqs"

  values = {
    name = values.name
  }
}

unit "lambda" {
  source = "${find_in_parent_folders("_units/aws/lambda")}"

  path = "lambda"

  values = {
    name = values.name
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
