# Helm Chart 설정 가이드

## API 서버 차트
### 주요 기능
* Deployment를 통한 파드 관리
* 서비스를 통한 네트워크 노출
* 헬스체크 엔드포인트 제공

## PostgreSQL 차트

## PostgreSQL 차트
1. Bitnami PostgreSQL 차트를 사용하여 PostgreSQL을 정의합니다
(Bitnami PostgreSQL repository)[https://github.com/bitnami/charts/tree/main/bitnami/postgresql]

2. 데이터베이스 고가용성을 위해 Streaming replication을 도입합니다.
