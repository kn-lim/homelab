resource "kubernetes_secret_v1" "token" {
  metadata {
    name      = var.token_secret_name
    namespace = var.namespace
  }

  data = {
    token = var.token
  }
}

# Optional: ArgoCD Registration

resource "kubernetes_service_account_v1" "argocd_manager" {
  count = var.argocd_registration != null ? 1 : 0

  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding_v1" "argocd_manager" {
  count = var.argocd_registration != null ? 1 : 0

  metadata {
    name = "argocd-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_manager[0].metadata[0].name
    namespace = kubernetes_service_account_v1.argocd_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_secret_v1" "argocd_manager" {
  count = var.argocd_registration != null ? 1 : 0

  metadata {
    name      = "argocd-manager-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argocd_manager[0].metadata[0].name
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "onepassword_item" "argocd_registration" {
  count = var.argocd_registration != null ? 1 : 0

  vault    = data.onepassword_vault.argocd_registration[0].uuid
  title    = var.argocd_registration.secret_name
  category = "login"

  section_map = {
    "Details" = {
      field_map = {
        server = {
          type  = "CONCEALED"
          value = var.argocd_registration.cluster_endpoint
        }
        bearer_token = {
          type  = "CONCEALED"
          value = kubernetes_secret_v1.argocd_manager[0].data["token"]
        }
        ca_data = {
          type  = "CONCEALED"
          value = base64encode(kubernetes_secret_v1.argocd_manager[0].data["ca.crt"])
        }
      }
    }
  }
}
