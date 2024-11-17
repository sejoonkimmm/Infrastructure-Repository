# Infrastructure Setup Project

## 프로젝트 개요
### 목적
1. Kubernetes(minikube) 환경에서 HealthCheck 및 CRUD API 서버 구축
2. Database 구축 및 연동
3. Terraform을 구성하여 인프라를 자동화
4. Helm Chart를 구성 및 활용하여 애플리케이션을 배포

### 기술 스택
- **Terraform v1.5.7**
- **Docker v24.0.6**
- **Minikube v1.31.0**
- **Helm v3.16.3**
- **PostgreSQL (Bitnami Helm Chart)**

API 서버 구현 간 사용한 기술 스택 및 선정 근거는 [API Server Repository](https://github.com/sejoonkimmm/API-Repository) 링크를 통해 확인하실 수 있습니다.


## 아키텍처 구상도 및 폴더 구조
### 전체 아키텍처
![minikube](https://github.com/user-attachments/assets/78cc2f79-1a81-48c7-b401-bf0821563471)

### 폴더 구조
```
INFRA/
├── helm/
│   ├── api-server/
│   │   ├── templates/
│   │   │   ├── deployment.yaml
│   │   │   └── service.yaml
│   │   ├── Chart.yaml
│   │   └── values.yaml
├── images/
│   └── ...
├── manual_test/
│   ├── test-api.yml
│   └── test-db.yml
└── terraform/
   ├── .terraform/
   ├── main.tf
   ├── providers.tf
   ├── variables.tf
   ├── terraform.tfvars
   ├── terraform.tfstate
   ├── terraform.tfstate.backup
   └── .gitignore
```

### 폴더 구조 구성 근거
(Terraform 표준 폴더 구조)[https://developer.hashicorp.com/terraform/language/modules/develop/structure]

(Helm Chart 작성 가이드)[https://helm.sh/docs/topics/charts/]

## 구축 결과 보고
### 구축 순서
1. [Minikube 설정](docs/minikube-setup.md)
   - 로컬 개발 환경에서의 쿠버네티스 클러스터 검증
   - 비용 효율적인 테스트 환경

2. [Helm, Terraform 구성 전 수동 테스트](docs/manual-test.md)
   - Helm Chart 작성을 위한 기초 자료 수집
   - 각 컴포넌트의 독립적 검증
   - 문제 발생 시 신속한 디버깅

3. [Terraform 구성](docs/terraform-setup.md)

4. [Helm Chart 구성](docs/helm-setup.md)

### 필수 구현 사항
1. ✅ Minikube Cluster 구성
   - 안정적인 로컬 쿠버네티스 환경 구축
2. ✅ PostgreSQL StatefulSet 배포
   - 영구 스토리지 구성
   - 데이터 일관성 보장
   - Streaming Replication 구성
3. ✅ CRUD API Server 배포
   - Health Check 엔드포인트 구현
   - CRUD API 구현
   - Swagger를 통한 문서화
4. ✅ Infrastructure as Code
   - Terraform 기반 인프라 관리
   - Helm Chart를 통한 애플리케이션 배포 자동화

### 배포 결과

**클러스터 상태**
```bash
kubectl get all -n my-app
```

![alt text](images/kubectl_resource_all.png)

**API테스트 결과**
1. Health Check Endpoint

![alt text](images/healthcheck.png)

2. Swagger API 테스트
   - TODO Create

   ![alt text](images/todocreate.png)

   - TODO Read(list)

   ![alt text](images/todolist.png)

   - TODO Update

   ![alt text](images/todoupdate.png)

   - TODO Delete

   ![alt text](images/tododelete.png)


## 추가 구현 사항
### 완료된 개선 사항
1. 강화된 Health Check 시스템
   - Kubernetes 환경 정보 제공
   - DB 연결 상태 모니터링
   - 상세 지연 시간 측정
   - 종합적 시스템 상태 로깅
2. Github Action CI 구축
   - 자동화된 Code convention 검사
   - 자동화된 컨테이너 빌드 및 업로드
3. 데이터베이스 고가용성
   - Streaming Replication 구성

### 향후 구현 계획
1. 강화된 API Server
   - 예외 처리 체계 개선
   - 로깅 시스템 강화
2. 모니터링 시스템 구축
   - Prometheus 메트릭 수집
   - Grafana 대시보드 구성
3. CD 파이프라인 구축
   - ArgoCD 기반 무중단 배포
   - 자동화된 테스트 통합
