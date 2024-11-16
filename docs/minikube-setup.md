# Minikube 환경 구성 가이드

## Minikube 클러스터 생성

```bash
minikube start \
    --cpus=2 \
    --memory=4096 \
    --disk-size=20g \
    --driver=docker \
    --kubernetes-version=v1.32.2
```

## 클러스터 상태 확인
```
minikube status

# 현재 컨텍스트 확인
kubectl config current-context

# 전체 클러스터 정보 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes -o wide
```





