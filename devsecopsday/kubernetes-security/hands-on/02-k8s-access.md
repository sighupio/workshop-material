# ACCESSING THE KUBERNETES CLUSTER

You should have received an email containing all the information that will be also noted here.

## Instruction

### Accessing the cluster

If you are following the workshop on-site, in order to access the cluster, you need to have a `ssh` client installed on your machine.
Node: For windows something like puTTY should do the job.

Once you have everything installed/ready you can connect to the cluster master node via the following command:

```bash
ssh -i name.surname@sighup.io.key -l workshop <master-node-ip>
```

Or connect to a worker node:

```bash
ssh -l workshop -i name.surname@sighup.io.key -o ProxyCommand="ssh -o StrictHostKeyChecking=no -W %h:%p -q -i name.surname@sighup.io.key -l workshop <master-node-ip>" 
```  

If you want to spin up a local cluster, use the following command:  
```bash
minikube start --driver=docker --network-plugin=cni --cni=calico --profile k8s-security-cluster --memory 8192 --cpus 4
```  




Once connected you can try a `kubectl` command like:

```bash
kubectl get nodes
```

This should give you the list of nodes available in you cluster. If any issue should arise, don't hesitate to let the teacher know.

Continue to [CIS Benchmarks](03-cis-benchmarks.md)