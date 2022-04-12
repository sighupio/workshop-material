# Network Policy

In this exercise we're going to create two pods `frontend` and `backend` and test their connectivity before and after applying a network policy.

1. Create a `test` namespace

```bash
kubectl create namespace test
```

2. Deploy a pod `nginx` in the `test` namespace called `frontend`. Expose it via a ClusterIP service on port 80.

```bash
kubectl run frontend --image=registry.sighup.io/workshop/nginx --namespace=test
kubectl expose pod frontend --port 80 --namespace=test
```

3. Deploy a pod `nginx` in the `test` namespace called `backend`. Expose it via a ClusterIP service on port 80.

```bash
kubectl run backend --image=registry.sighup.io/workshop/nginx --namespace=test
kubectl expose pod backend --port 80 --namespace=test
```

4. Check that everything works correctly

```bash
kubectl get pod,svc -n test
```

5. Check connectivity from frontend to backend

```bash
kubectl exec frontend -n test -- curl backend
```

> when using curl `backend` we're referencing the ClusterIP service
> More info on dns can be found [here](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

6. Check connectivity from backend to frontend

```bash
kubectl exec backend -n test -- curl frontend
```

7. Create a `default-deny` network policy both from Ingress and Egress.

8. Check connectivity again

> NOTE:
> You should not be able to reach the frontend from the backend (and viceversa).
> In case you can, make sure that you solution is correct.
> If you are absolutely sure that your solution is correct, then make sure that you have the CNI Cilium correctly configured
> An alternative way to deploy Cilium can be found [here](https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/cilium-network-policy/)

9. Allow connectivity from frontend to backend.

    - Define a Network policy called `frontend-policy` in the `test` namespace that applies to the frontend pod (check the labels necessary).
      This policy should allow Egress traffic on port `80` and protocol `TCP` from backend pod (check the labels necessary)

    - Define a Network policy called `backend-policy` in the `test` namespace that applies to the backend pod (check the labels necessary).
      This policy should allow Ingress traffic on port `80` and protocol `TCP` from frontend pod (check the labels necessary)

10. Check connectivity again:

```bash
kubectl exec frontend -n test -- curl backend
```

> This should not work!
> Why?
> Our default deny policy block also the DNS resolution query of the `backend` service!

We need to use the IP of the pod instead of the name of the service!

```bash
# Get the ip of the backend
kubectl get pod backend -n test -o jsonpath="{.status.podIP}"
# 10.0.0.204

kubectl exec frontend -n test -- curl 10.0.0.204
# Should work :)
```