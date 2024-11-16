resource "kubernetes_namespace" "app" {
  metadata {
    name = "my-app"
  }
}

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    password = var.db_password
    "database-url" = "postgresql://postgres:${var.db_password}@postgresql:5432/apidb"
  }
}
resource "helm_release" "postgresql" {
  name      = "postgresql"
  namespace = kubernetes_namespace.app.metadata[0].name
  chart     = "../helm/postgresql"

  depends_on = [kubernetes_secret.db_credentials]
}
resource "helm_release" "api_server" {
  name      = "api-server"
  namespace = kubernetes_namespace.app.metadata[0].name
  chart     = "../helm/api-server"

  depends_on = [helm_release.postgresql]
}