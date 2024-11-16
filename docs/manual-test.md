# 수동 배포 테스트 가이드
Helm Chart 작성 및 Terraform 구성 전 수동으로 각 컴포넌트를 배포하고 테스트하는 과정을 다룬 문서입니다.

## PostgreSQL 배포 테스트

### 기본 배포
1. db-test.yml 파일 작성
```bash
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      securityContext:
        fsGroup: 1001
        runAsUser: 1001
      containers:
      - name: postgres
        image: bitnami/postgresql:16
        env:
        - name: POSTGRESQL_USERNAME     
          value: "postgres"
        - name: POSTGRESQL_PASSWORD       
          value: "testpassword"
        - name: POSTGRESQL_DATABASE       
          value: "testdb"
        - name: POSTGRESQL_VOLUME_DIR      
          value: "/bitnami/postgresql"
        - name: POSTGRESQL_DATA_DIR       
          value: "/bitnami/postgresql/data"
        - name: ALLOW_EMPTY_PASSWORD       
          value: "no"
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /bitnami/postgresql
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

2. test용 postgreSQL service 생성

3. 배포 상태 확인
```bash
kubectl get statefulset,svc,pods
```

## 참고 사항
### Bitmani 이미지 선정 근거
1. Kubernetes 환경에 최적화된 image
2. non-root 유저로 실행되어 보안에 최적화
3. Kubernetes 환경에 맞는 환경변수 및 설정 제공
4. 추후 Helm chart를 이용한 배포 시에도 사용하기에 용이

[Bitnami PostgreSQL 이미지 문서](https://hub.docker.com/r/bitnami/postgresql)

## API 서버 배포 테스트

### 기본 배포
1. api-test.yml 파일 생성
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api-server
        image: sejokim/api-server:latest
        imagePullPolicy: Always
        command: ["python"]
        args: ["-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:testpassword@postgres:5432/testdb"
        - name: PYTHONUNBUFFERED
          value: "1"
        resources:
          requests:
            cpu: "200m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
```

2. API 서버용 Service 생성
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-server
spec:
  selector:
    app: api-server
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
```

3. 배포 상태 확인
```bash
kubectl get deployment,svc,pods
```

```bash
manual_test % k get deployment,svc,pods
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/api-server   1/1     1            1           3m25s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/api-server   ClusterIP   10.105.131.89    <none>        8000/TCP   76s
service/kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    4m27s
service/postgres     ClusterIP   10.104.185.206   <none>        5432/TCP   3m29s

NAME                              READY   STATUS    RESTARTS   AGE
pod/api-server-5dd984595f-sfrvd   1/1     Running   0          3m25s
pod/postgres-0                    1/1     Running   0          3m29s
```

### 연결 테스트
1. 서비스 상태 확인
```bash
kubectl get all
```

```bash
k get all
NAME                              READY   STATUS    RESTARTS   AGE
pod/api-server-5dd984595f-sfrvd   1/1     Running   0          3m53s
pod/postgres-0                    1/1     Running   0          3m57s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/api-server   ClusterIP   10.105.131.89    <none>        8000/TCP   104s
service/kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    4m55s
service/postgres     ClusterIP   10.104.185.206   <none>        5432/TCP   3m57s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/api-server   1/1     1            1           3m53s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/api-server-5dd984595f   1         1         1       3m53s

NAME                        READY   AGE
statefulset.apps/postgres   1/1     3m57s
```

2. API 서버 연결 테스트
포트포워딩
```bash
kubectl port-forward svc/api-server 8000:8000
```

healthcheck
```bash
curl http://localhost:8000/health
```

결과
```bash
curl localhost:8000/health | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   118  100   118    0     0   5703      0 --:--:-- --:--:-- --:--:--  5900
{
  "status": "healthy",
  "timestamp": "2024-11-16T10:23:32.165100",
  "details": {
    "database": "connected",
    "api_version": "1.0.0"
  }
```

## 테스트 완료 결과
### 구성 요소 상태
✅ PostgreSQL StatefulSet 정상 동작
✅ PostgreSQL Service 정상 동작
✅ API 서버 Deployment 정상 동작
✅ API 서버 Service 정상 동작
✅ 데이터베이스 연결 성공
✅ Health Check 응답 정상