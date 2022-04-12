# Question 3 - Pod Placement

Deploy a pod with name `nginx-jke3` with the image `registry.sighup.io/workshop/nginx:alpine` in the default namespace.
The pod should be scheduled **only** on the **master nodes**.
The solution should work in case the number of master nodes increase in the future.

Do not edit the master node definition.

## Solution

Create a `nginx_pod.yaml` file. Containing a:

- Toleration for the master `node-role.kubernetes.io/master:NoSchedule` taint
- Affinity for the label `node-role.kubernetes.io/master`

```yaml
# file: ./nginx_pod.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-jke3
spec:
  containers:
  - image: registry.sighup.io/workshop/nginx
    name: nginx-jke3
  tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"
  affinity:
    nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
            - key: node-role.kubernetes.io/master
              operator: Exists
```

Apply the manifest:

```bash
kubectl apply -f nginx_pod.yaml
```
