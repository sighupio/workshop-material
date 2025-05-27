Now that you've approved your Certificate Signing Request (CSR) and obtained the signed certificate, you can generate a kubeconfig file to use the certificate for authentication


### Prerequisites

1. Private key: new-user.key
2. Signed certificate: my-certificate.crt
3. CA certificate: You need the Kubernetes cluster’s CA certificate, which is usually available in the default kubeconfig or from your admin.

You can get the cluster’s CA certificate from the existing kubeconfig with this command

```bash
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > kube-ca.crt
```

Now, generate a new kubeconfig file that uses your certificate for authentication. Use the following template to create the kubeconfig file:

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: ./kube-ca.crt
    server: https://<KUBE_API_SERVER>
  name: my-cluster
contexts:
- context:
    cluster: my-cluster
    user: my-k8s-user
  name: my-context
current-context: my-context
users:
- name: my-k8s-user
  user:
    client-certificate: ./my-certificate.crt
    client-key: ./new-user.key
```

You need to replace the server field in the template (https://<KUBE_API_SERVER>) with the actual API server endpoint of your Kubernetes cluster. To find this, run:

```bash
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}'
```

You also need to retrieve the signed certificate

```bash
kubectl get csr my-csr -o jsonpath='{.status.certificate}' | base64 --decode > my-certificate.crt
```

Now we can use the newly generated kubeconfig to interact with the Kubernetes cluster:

```bash
kubectl --kubeconfig=./kubeconfig get nodes
```

But we receive an error:

Error from server (Forbidden): nodes is forbidden: User "my-k8s-user" cannot list resource "nodes" in API group "" at the cluster scope

This is because our user is using a valid authentication file (they can authenticate), but they do not have the permissions to interact with Kubernetes objects (it fails at the authorization stage).

We can then grant them permissions using a ClusterRoleBinding.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-k8s-user-binding  # You can give it any name
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin  # This grants full permissions
subjects:
- kind: User
  name: my-k8s-user  # This should match the CN of your certificate
  apiGroup: rbac.authorization.k8s.io
```

And verify that the call

```bash
kubectl --kubeconfig=./kubeconfig get nodes
```

was successful!
