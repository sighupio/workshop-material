# Networking


Apply the manifest to create the deployment and service:  

```bash
kubectl apply -f hands-on/k8s/sample-app.yaml
```  

Verify that the deployment and service are created successfully by ensuring that  
the sample app deployment `sample-app`  and service `sample-service`  are listed:

```bash
kubectl get deployment,service
```  

Output:

```bash
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/sample-app   2/2     2            2           42s

NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP   5m41s
service/sample-service   ClusterIP   10.98.222.155   <none>        80/TCP    42s
```  

Overview of Network Policies:  

Explain the concept of Network Policies, which allow you to control ingress and egress traffic to pods based on specific criteria such as source IP, protocol, or ports.  

Example of Basic Network Policy for Pod Traffic Control:  

Create a YAML manifest file named basic-network-policy.yaml with the following content:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-traffic
spec:
  podSelector:
    matchLabels:
      app: allowed-app
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: sample-app
```

This example Network Policy allows traffic to the pods labeled with `app: sample-app` from pods labeled with `app: allowed-app`.  
Apply the Network Policy to the default namespace:

```bash
kubectl apply -f hands-on/k8s/basic-network-policy.yaml -n default
```

The Network Policy is applied, and traffic will be allowed only from pods labeled as `app: allowed-app` to pods labeled as `app: sample-app`.  
Example of Network Policy to Block Cluster Egress Traffic:  

Create a YAML manifest file named block-egress-traffic.yaml with the following content:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
spec:
  podSelector: {}
  policyTypes:
  - Egress

```

This Network Policy blocks all egress traffic from pods in the namespace.  

Apply the Network Policy to the default namespace:

```bash
kubectl apply -f hands-on/k8s/block-egress-traffic.yaml -n default
```  

## Testing Network Policies

Test the basic network policy for pod traffic control:

Create a new pod labeled as app: allowed-app:

```bash
kubectl run allowed-app --image=nginx --labels=app=allowed-app
```  

Retrieve the service IP:

```bash
kubectl get service sample-service -o jsonpath='{.spec.clusterIP}'
```  


Access the shell of the allowed-app pod (once the pod is up and running):

```bash
kubectl exec -it allowed-app -- /bin/bash
```

Use curl to reach the service:

```bash
curl <SERVICE-IP>
```

Output:

```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Exit the pod shell:

```bash
exit
```  

Test the network policy to block cluster egress traffic:  

Create a new pod for testing:  

```bash
kubectl run test-pod --image=nginx
```

Access the shell of the test-pod (once the pod is up and running) and try to call an external url (nn this case one of the google servers):


```bash
kubectl exec -it test-pod -- /bin/bash -c "curl --max-time 10 216.58.204.142"
```

This request will time out, indicating that the policy to block egress traffic is working:

```bash
curl: (28) Connection timed out after 10001 milliseconds
```  

now you can exit the pod shell:

```bash
exit
```

If you want proof that our policy was blocking egress traffic you can delete the policy and re-try the previous step, it will work!  

Continue to [Gatekeeper](06-gatekeeper.md)
