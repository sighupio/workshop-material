# GET YOUR HANDS DIRTY

## Instruction
First thing first, we need to spin up our local development cluster.  
In order to do this, launch the following command:  
```console
minikube start --driver=docker --profile tekton-cluster --memory 8192 --cpus 4
```  

Output:
```console
😄  [tekton-cluster] minikube v1.30.1 on Darwin 13.3.1
✨  Using the docker driver based on user configuration
📌  Using Docker Desktop driver with root privileges
👍  Starting control plane node tekton-cluster in cluster tekton-cluster
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=4, Memory=8192MB) ...
🐳  Preparing Kubernetes v1.26.3 on Docker 23.0.2 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "tekton-cluster" cluster and "default" namespace by default
```

Now we can enable the `metrics-server` addon (this is not mandatory for the demo, just useful if we want to inspect some metrics later):
```console
minikube --profile tekton-cluster addons enable metrics-server
```  

Output:
```console
💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image registry.k8s.io/metrics-server/metrics-server:v0.6.3
🌟  The 'metrics-server' addon is enabled
```  
>Note that the metrics server takes a while to be up and running

Confirm that our cluster is up and running by retrieving the pods in all namespaces:
```console
kubectl get pods -A
```  
Output:
```console
NAMESPACE     NAME                                     READY   STATUS    RESTARTS       AGE
kube-system   coredns-787d4945fb-84swb                 1/1     Running   0              4m36s
kube-system   etcd-tekton-cluster                      1/1     Running   0              4m51s
kube-system   kube-apiserver-tekton-cluster            1/1     Running   0              4m50s
kube-system   kube-controller-manager-tekton-cluster   1/1     Running   0              4m51s
kube-system   kube-proxy-22ggt                         1/1     Running   0              4m36s
kube-system   kube-scheduler-tekton-cluster            1/1     Running   0              4m50s
kube-system   metrics-server-6588d95b98-wfwz9          1/1     Running   0              2m20s
kube-system   storage-provisioner                      1/1     Running   1 (4m6s ago)   4m47s
```  

Continue to [Tekton](04-tekton.md)
