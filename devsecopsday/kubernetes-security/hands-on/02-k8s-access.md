# ACCESSING THE KUBERNETES CLUSTER

You should have received an email containing all the information that will be also noted here.

## Instruction

### Accessing the cluster

In order to access the cluster, you need to have a `ssh` client installed on your machine.
Node: For windows something like puTTY should do the job.

Once you have everything installed/ready you can connect to the cluster master node via the following command:

```bash
ssh -i name.surname@sighup.io.key -l workshop <master-node-ip>
```

Or connect to a worker node:

```bash
ssh -l workshop -i name.surname@sighup.io.key -o ProxyCommand="ssh -o StrictHostKeyChecking=no -W %h:%p -q -i name.surname@sighup.io.key -l workshop <master-node-ip>" 
```

Once connected you can try a `kubectl` command like:

```bash
kubectl get nodes
```

This should give you the list of nodes available in you cluster. If any issue should arise, don't hesitate to let the teacher know.

Continue to [CIS Benchmarks](03-cis-benchmarks.md)