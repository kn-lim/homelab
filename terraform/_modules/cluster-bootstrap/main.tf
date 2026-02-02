resource "kubernetes_secret_v1" "token" {
  metadata {
    name      = var.token_secret_name
    namespace = var.namespace
  }

  data = {
    token = var.token
  }
}
