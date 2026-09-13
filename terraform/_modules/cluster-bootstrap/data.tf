data "onepassword_vault" "argocd_registration" {
  count = var.argocd_registration != null ? 1 : 0

  name = var.argocd_registration.vault_name
}
