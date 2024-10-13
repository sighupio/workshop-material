Users in K8s are managed via CRTs and the CN/CommonName field in them. The cluster CA needs to sign these CRTs.

This can be achieved with the following procedure:


In the first step we'll create a CSR and in the second step we'll manually sign the CSR with the K8s CA file.

The idea here is to create a new "user" that can communicate with K8s.

For this now:

1. Create a KEY (Private Key) file
2. Create a CSR (CertificateSigningRequest) file for that KEY
3. Create a CRT (Certificate) by signing the CSR. Done using the CA (Certificate Authority) of the cluster

Commands:

```bash
openssl genrsa -out new-user.key 2048
```

```bash
openssl req -new -key new-user.key -out new-user.csr -subj "/CN=my-k8s-user/O=my-k8s-group"
```

To check the new csr created:

```bash
openssl req  -noout -text -in new-user.csr
```

```bash
cat new-user.csr | base64 | tr -d '\n' > mycsr-base64.txt
```

At this point we can create our Certificate Signing Request in Kubernetes (name this file csr.yml)

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: my-csr
spec:
  request: <BASE64_ENCODED_CSR>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
```

```bash
sed "s|<BASE64_ENCODED_CSR>|$(cat mycsr-base64.txt)|" csr.yml > my-csr.yaml
```

And we can apply the new CertificateSigningRequest

```bash
kubectl apply -f my-csr.yaml
```

Once the CertificateSigningRequest (CSR) resource is created and submitted to Kubernetes, here's the general process that follows:

1. The CSR Will Be in "Pending" state, it is waiting for approval.

```bash
kubectl get csr
```

2. A Kubernetes admin (or someone with the appropriate permissions) must manually approve the request. Kubernetes does not automatically sign CSRs. To approve the CSR, run:

```bash
kubectl certificate approve my-csr
```

3. Check the csr status after approval: Once approved, the status of the CSR will change from Pending to Approved (or Denied if the request is rejected). To check the status again, run

```bash
kubectl get csr
```