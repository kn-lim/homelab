stack "dreamingway-bot" {
  source = "${find_in_parent_folders("_stacks/dreamingway-bot")}"

  path = "dreamingway-bot"

  values = {
    name             = "dreamingway-bot"
    admin_role_users = ""

    discord_api_version = "10"

    credential = {
      vault_name  = "Homelab"
      secret_name = "dreamingway-bot"
    }

    debug = "false"
  }
}
