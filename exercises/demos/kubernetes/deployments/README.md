# Pods, ReplicaSets, Deployments

Now you should know all the theory behind `Pods`, `ReplicaSets`, `ReplicationControllers` and `Deployments` but **what are they**?

here is a simple example of `Deployment`:

```yaml
apiVersion: apps/v1 # Version of the Kubernetes API to use, necessary for kubectl
kind: Deployment
metadata:
  name: nginx-deployment # Name referenced during the deployment life
spec:
  replicas: 3 # Desired state ensured by rs
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels: # Labels (simple key-values) associated with the pod
        app: nginx
    spec:
      containers: # The actual containers, a simple nginx exposing port 80
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

# Let's play a bit

Let's define a baseline: we will issue all our commands from `$PROJECT_HOME/kubernetes`

First of all, let's see the current state of our cluster:

```bash
kubectl get nodes

NAME       STATUS    ROLES     AGE       VERSION
minikube   Ready     <none>    52s       v1.9.0
```

```bash
kubectl get pods

No resources found
```

So, we have a clean cluster!

### Let's create our first deployment.

```bash

kubectl apply -f deployments/nginx-deployment.yaml

---

kubectl get pods --show-labels

NAME                                READY     STATUS    RESTARTS   AGE       LABELS
nginx-deployment-4234284026-02j4d   1/1       Running   0          3m        app=nginx,pod-template-hash=4234284026
nginx-deployment-4234284026-267f6   1/1       Running   0          3m        app=nginx,pod-template-hash=4234284026
nginx-deployment-4234284026-g9819   1/1       Running   0          3m        app=nginx,pod-template-hash=4234284026

---

kubectl get rs

NAME                          DESIRED   CURRENT   READY     AGE
nginx-deployment-4234284026   3         3         3         2m

---

kubectl rollout status deployment/nginx-deployment

deployment "nginx-deployment" successfully rolled out

```

As defined in our `nginx-deployment.yaml` we now have 3 running pods in our cluster, all running `nginx version 1.7.9` and with the labels set as expected.

### Rolling an update

Let's imagine now that we want to change something in our image, update for example the nginx version we are running.

```yaml
...
    spec:
      containers:
      - name: nginx
        image: nginx:1.9.1
        ports:
...

```

and let's apply our change

```bash
kubectl apply -f deployments/nginx-deployment.yaml
deployment "nginx-deployment" configured

---

kubectl get pods 

NAME                                READY     STATUS              RESTARTS   AGE
nginx-deployment-3646295028-8k2z5   1/1       Terminating         0          1m
nginx-deployment-3646295028-8ssg5   0/1       Terminating         0          1m
nginx-deployment-3646295028-tmdlv   1/1       Running             0          1m
nginx-deployment-4234284026-h6bxw   1/1       Running             0          3s
nginx-deployment-4234284026-hc6x5   1/1       Running             0          5s
nginx-deployment-4234284026-wscvp   0/1       ContainerCreating   0          2s

---

kubectl get rs

NAME                          DESIRED   CURRENT   READY     AGE
nginx-deployment-3646295028   0         0         0         10m
nginx-deployment-4234284026   3         3         3         3m

```

What we see here is super-interesting. As soon as we rolled out our update, kubernetes has started to `terminate` running pods with the old version and has created new ones aligned with the new state we have specified. It has done that, by creating a new `ReplicaSet` for the updated version of our deployment. So the old `ReplicaSet` gradually diminished the number of running pods while the new `ReplicaSet` Increased it to finally reach desired state.

To see how exactly the deployment has handled the rollout we use the **describe** command.

```bash
kubectl describe deployment nginx-deployment

Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Tue, 20 Mar 2018 09:46:27 +0100
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision=2
                        kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"apps/v1beta1","kind":"Deployment","metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},"spec":{"replicas":3,"te...
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx:1.9.1
    Port:         80/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-5964dfd755 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  40s   deployment-controller  Scaled up replica set nginx-deployment-6c54bd5869 to 3
  Normal  ScalingReplicaSet  18s   deployment-controller  Scaled up replica set nginx-deployment-5964dfd755 to 1
  Normal  ScalingReplicaSet  17s   deployment-controller  Scaled down replica set nginx-deployment-6c54bd5869 to 2
  Normal  ScalingReplicaSet  17s   deployment-controller  Scaled up replica set nginx-deployment-5964dfd755 to 2
  Normal  ScalingReplicaSet  16s   deployment-controller  Scaled down replica set nginx-deployment-6c54bd5869 to 1
  Normal  ScalingReplicaSet  16s   deployment-controller  Scaled up replica set nginx-deployment-5964dfd755 to 3
  Normal  ScalingReplicaSet  13s   deployment-controller  Scaled down replica set nginx-deployment-6c54bd5869 to 0
```

### Rollbacking

What happens if we have a faulty update?

```yaml
...
    spec:
      containers:
      - name: nginx
        image: nginx:1.91
        ports:
...

```

```bash
kubectl apply -f deployments/nginx-deployment.yaml
```
```bash
kubectl get pods

NAME                                READY     STATUS         RESTARTS   AGE
nginx-deployment-3660254150-q07l4   0/1       ErrImagePull   0          12s
nginx-deployment-4234284026-h6bxw   1/1       Running        0          13m
nginx-deployment-4234284026-hc6x5   1/1       Running        0          13m
nginx-deployment-4234284026-wscvp   1/1       Running        0          13m
```

Kubernetes *will start the rollout but will notice that something is wrong with our application*. This will stop the whole process. If we didn't set otherwise in the deployment, kubernetes will try to re-apply the rollout forever giving us time to understand what is happening and take action.

```bash
kubectl rollout history deployment/nginx-deployment

deployments "nginx-deployment"
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>

---

kubectl rollout history deployment/nginx-deployment --revision=3

deployments "nginx-deployment" with revision #3
Pod Template:
  Labels:	app=nginx
	pod-template-hash=1817986819
  Containers:
   nginx:
    Image:	nginx:1.91
    Port:	80/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
```

Using history and revisions is a very powerful tool, they let you see what changed in your deployments. Also, they let you see which deployment was in a sane state and let you rollback to that point of time.

```bash
kubectl rollout history deployment/nginx-deployment --revision=2

deployments "nginx-deployment" with revision #2
Pod Template:
  Labels:	app=nginx
	pod-template-hash=1520898311
  Containers:
   nginx:
    Image:	nginx:1.9.1
    Port:	80/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>

---

kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

**This is going to instantly bring us back in time** to a moment where we knew our services were working.

### Last but not least: scaling a deployment

```bash
kubectl scale deployment nginx-deployment --replicas=10
deployment "nginx-deployment" scaled

kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
nginx-deployment-4234284026-1g7nq   1/1       Running   0          20s
nginx-deployment-4234284026-8cdmw   1/1       Running   0          20s
nginx-deployment-4234284026-d8s3p   1/1       Running   0          20s
nginx-deployment-4234284026-h6bxw   1/1       Running   0          22m
nginx-deployment-4234284026-hc6x5   1/1       Running   0          22m
nginx-deployment-4234284026-k937g   1/1       Running   0          20s
nginx-deployment-4234284026-qgd9d   1/1       Running   0          20s
nginx-deployment-4234284026-t8zw6   1/1       Running   0          20s
nginx-deployment-4234284026-wgsqx   1/1       Running   0          20s
nginx-deployment-4234284026-wscvp   1/1       Running   0          22m
```
