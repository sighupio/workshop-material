# ETCD

**etcd** is a consistent and highly-available key value store used as Kubernetes' backing store for all cluster data.

Kubeadm defaults to running a single member etcd cluster in a static pod managed by the kubelet on the control plane node. This is not a high availability setup as the etcd cluster contains only one member and cannot sustain any members becoming unavailable.

Find the pod that it's running etcd:

```bash
export ETCD_POD=$(kubectl get pods -n kube-system -o wide | grep etcd | awk '{print $1}')
```

Save the pod IP in an environment variable:

```bash
export ENDPOINT=$(kubectl get pods -n kube-system -o wide | grep etcd | awk '{print $6}')
```

Run the etcdctl command from inside one of those pods to retrieve the etcd version running

```bash
kubectl -n kube-system exec $ETCD_POD -- sh -c "etcdctl version"
```

Check the `etcd` configuration located in `etc/kubernetes/manifests/etcd.yaml`:

```bash
cat /etc/kubernetes/manifests/etcd.yaml
```

## Common etcd commands 

See the status:

```bash
ETCDCTL_API=3 sudo etcdctl endpoint status \
    --endpoints=https://$ENDPOINT:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --write-out=table 
```

List the members ot etcd cluster:

```bash
ETCDCTL_API=3 sudo etcdctl member list \
    --endpoints=https://$ENDPOINT:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --write-out=table 
```

Backup etcd cluster:

```bash
ETCDCTL_API=3 sudo etcdctl snapshot save my_snapshot \
    --endpoints=https://$ENDPOINT:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key 
```

See the status of the snapshot:

```bash
ETCDCTL_API=3 sudo etcdctl snapshot status my_snapshot \
    --endpoints=https://$ENDPOINT:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --write-out=table 
```

To eventually restore etcd cluster: 

```bash
ETCDCTL_API=3 sudo etcdctl snapshot restore my_snapshot \
    --endpoints=https://$ENDPOINT:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key 
```

