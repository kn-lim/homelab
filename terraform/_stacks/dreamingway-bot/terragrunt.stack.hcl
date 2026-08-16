unit "onepassword-secret-read" {
  source = "${find_in_parent_folders("_units/onepassword-secret-read")}"

  path = "onepassword-secret-read"

  values = {
    vault_name  = values.credential.vault_name
    secret_name = values.credential.secret_name
  }
}

unit "chattingway" {
  source = "${find_in_parent_folders("_units/chattingway")}"

  path = "chattingway"

  autoinclude {
    dependency "onepassword-secret-read" {
      config_path = unit.onepassword-secret-read.path

      mock_outputs = {
        fields = {
          application_id = "application_id"
          public_key     = "public_key"
          token          = "token"
        }
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      enable_counter_table = try(values.enable_counter_table, false)

      endpoint_environment_variables = {
        ADMIN_ROLE_USERS           = values.admin_role_users
        DEBUG                      = values.debug
        DISCORD_BOT_APPLICATION_ID = dependency.onepassword-secret-read.outputs.fields["application_id"]
        DISCORD_BOT_PUBLIC_KEY     = dependency.onepassword-secret-read.outputs.fields["public_key"]
        DISCORD_BOT_TOKEN          = dependency.onepassword-secret-read.outputs.fields["token"]
        TASK_FUNCTION_NAME         = "${values.name}-task"
      }

      task_environment_variables = {
        COUNTER_DISCORD_ADMIN_ROLE = try(values.counter_admin_role, "")
        COUNTER_TABLE_NAME         = "${values.name}-counters"
        DEBUG                      = values.debug
        DISCORD_API_VERSION        = values.discord_api_version
        DISCORD_BOT_TOKEN          = dependency.onepassword-secret-read.outputs.fields["token"]
      }
    }
  }

  values = {
    name = values.name
  }
}
