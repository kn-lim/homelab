stack "webhook" {
  source = "${find_in_parent_folders("_stacks/webhook")}"

  path = "webhook"

  values = {
    name = "homelab"

    vault_name  = "Homelab"
    secret_name = "github"
  }
}
