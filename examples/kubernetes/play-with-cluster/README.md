# Init
## ***Step 1 - SSH into your Kubernetes Cluster***
```
ssh cluster

```
## ***Step 2 - Create your first pod***
```
kubectl run test --image gcr.io/google-samples/hello-app:1.0 
```

## ***Step 3 - Play with this commands***
```
kubectl get pods -w

kubectl get pods -o wide

kubectl logs test

kubectl describe pod 
```

## ***Step 4 - Delete your pod***
```
kubectl delete pod test
```
