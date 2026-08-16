stack "lplaziv-bot" {
  source = "${find_in_parent_folders("_stacks/dreamingway-bot")}"

  path = "lplaziv-bot"

  values = {
    name             = "lplaziv-bot"
    admin_role_users = ""

    discord_api_version = "10"

    credential = {
      vault_name  = "Homelab"
      secret_name = "lplaziv-bot"
    }

    debug = "false"
  }
}
