# Terraform 설정 가이드
## 주요 리소스

### 네임스페이스
애플리케이션을 위한 Namespace를 생성합니다.

```terraform
resource "kubernetes_namespace" "app" {
  metadata {
    name = "my-app"
  }
}
```

클러스터 리소스 및 서비스의 모니터링을 위한 monitoring namespace를 생성합니다.

```terraform
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
```



### 시크릿
데이터베이스 자격증명을 안전히 관리합니다.
```terraform
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    password      = var.db_password
    database-url  = "postgresql://postgres:${var.db_password}@postgresql:5432/apidb"
  }
}
```

### Helm Chart 배포
PostgreSQL과 API Server를 Helm Chart를 통해 배포합니다.

```bash
resource "helm_release" "postgresql" {
  name      = "postgresql"
  namespace = kubernetes_namespace.app.metadata[0].name
  chart     = "../helm/postgresql"
}

resource "helm_release" "api_server" {
  name      = "api-server"
  namespace = kubernetes_namespace.app.metadata[0].name
  chart     = "../helm/api-server"
  depends_on = [helm_release.postgresql]
}
```

## 배포 방법
1. Terraform 초기화 및 배포
```bash
terraform init
terraform plan
terraform apply
```

2. 배포 확인
```bash
kubectl get all -n my-app
```