# Encrypt Secrets in ETCD
In this lab we will setup ETCD encryption at rest for our kubernetes cluster. The encryption is carried out by the kube API server.

## Ensure the encryption is turned off
Let's examine the kube-apiserver manifest under `/etc/kubernetes/manifests/kube-apiserver.yaml` and make sure that there is no line containing
```yaml
- --encryption-provider-config=...
```
If there is one, something's wrong or you already enabled it (good job!). In this case, there's no need to proceed with the rest of the exercise.

## Let's create a Secret in the default namespace
But if you haven't enabled it yet, let's continue!

```bash
kubectl create secret generic super-secret --from-literal=super=secret
```

## Use the etcdctl utility to read the secret
We will notice that we can, in fact, read the secret, since it's stored in plain text!

```bash
# Run as the root user
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key get /registry/secrets/default/super-secret
# ... gibberish
# ...super secret Opaque..."
```

## Create a new `EncryptionConfiguration`
As the root user, create a new folder.
```plaintext
mkdir /etc/kubernetes/encryption
```

Now, still as the root user, create a new `EncryptionConfiguration` inside that folder.

```bash
cat<<EOF > /etc/kubernetes/encryption/enc.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aesgcm:
          keys:
            - name: key1
              secret: $(head -c 16 /dev/urandom | base64)
      - identity: {} # plain text used as fallback
EOF
```

## Tell the kube-apiserver to use it!
Add a new `hostPath` volume inside the `.volumes` array in the `/etc/kubernetes/manifests/kube-apiserver.yaml` manifest, so that the kube-apiserver Pod will have the folder available in its filesystem.
```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
# ...
volumes:
  # ...
  # Add this one!
  - hostPath:
      path: /etc/kubernetes/encryption
      type: DirectoryOrCreate
    name: encryption
  # ...
```

Then, tell the Pod where to mount the newly created volume.
```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
# ...
spec:
  containers:
  - command: 
    - kube-apiserver
    - --advertise-address=...
    # ...
    volumeMounts:
    - # ...
    # Add this one!
    - mountPath: /etc/kubernetes/encryption
      name: encryption
      readOnly: true
```

And finally, instruct the kube-apiserver binary where to find the configuration.
```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
# ...
spec:
  containers:
  - command: 
    - kube-apiserver
    # ...
    # add this one!
    - --encryption-provider-config=/etc/kubernetes/encryption/enc.yaml
    # ...
```

## Profit!
Now, after the kube-apiserver restarts, newly created secrets should be encrypted with our key!

In order to re-encrypt existing `Secrets` in the default namespace, use the following snippet:
```bash
kubectl get secrets -oyaml | kubectl replace -f -
```

## Ensure the Secrets are stored encrypted
```bash
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key get /registry/secrets/default/super-secret
# ... encrypted gibberish
```