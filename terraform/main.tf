resource "kubernetes_namespace" "app" {
  metadata {
    name = "my-app"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    password = var.db_password
    "database-url" = "postgresql://postgres:${var.db_password}@postgresql-primary:5432/apidb"
    replication_password = var.replication_password
    
  }
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  namespace  = kubernetes_namespace.app.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "16.0.2"

  dynamic "set" {
    for_each = local.postgresql_settings
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set_sensitive" {
    for_each = local.postgresql_sensitive_settings
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }

  depends_on = [kubernetes_secret.db_credentials]
}

resource "helm_release" "api_server" {
  name      = "api-server"
  namespace = kubernetes_namespace.app.metadata[0].name
  chart     = "../helm/api-server"

  depends_on = [helm_release.postgresql]
}

locals {
  postgresql_settings = {
    "architecture" = "replication"
    "auth.database" = "apidb"

    # Primary 설정
    "primary.persistence.size" = "2Gi"
    "primary.resources.requests.memory" = "256Mi"
    "primary.resources.requests.cpu" = "250m"
    "primary.resources.limits.memory" = "512Mi"
    "primary.resources.limits.cpu" = "500m"

    # ReadReplica 설정
    "readReplicas.replicaCount" = "1"
    "readReplicas.persistence.size" = "2Gi"
    "readReplicas.resources.requests.memory" = "256Mi"
    "readReplicas.resources.requests.cpu" = "250m"
    "readReplicas.resources.limits.memory" = "512Mi"
    "readReplicas.resources.limits.cpu" = "500m"
  }

  postgresql_sensitive_settings = {
    "auth.postgresPassword" = var.db_password
    "auth.replicationPassword" = var.replication_password
  }
}
