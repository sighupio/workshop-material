# OWASP TOP 10

## Lab Exercise 1: Container Image Security

### Objective
Learn how to secure container images and prevent common vulnerabilities in Kubernetes deployments.

### Task 1: Identify Vulnerable Images

1. **Deploy a Kubernetes Pod using a vulnerable container image:**

Apply the manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vulnerable-pod
spec:
  containers:
    - name: vulnerable-container
      image: httpd:2.4.41
```

```bash
kubectl apply -f hands-on/k8s/vulnerable-pod.yaml
```

We are using `httpd:2.4.41` because we know it has lots of known vulnerabilities.

2. **Verify that the pod is running:**

```bash
kubectl get pods
```

### Task 2: Implement Image Scanning

1. **Install Trivy in your machine:**

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.45.0
```

2. **Scan the vulnerable image:**

```bash
trivy image httpd:2.4.41
```

**Note**: This command's output may be a little too long, if you want to filter only CRITICAL vulnerabilities you can use the flag `-s CRITICAL`

```bash
trivy image httpd:2.4.41 -s CRITICAL
```

3. **Take a look at the vulnerabilities found and their potential impacts.**

### Task 3: Remediate Vulnerabilities

1. **Update the vulnerable container image in `vulnerable-pod.yaml` to a secure version.**

Before updating we want to do a scan on a newer version of `httpd` to see how many vulnerability are fixed and how many are still present.

```bash
trivy image httpd:2.4.57 -s CRITICAL
```

The output should be something like this:

```console
httpd:2.4.57 (debian 12.1)

Total: 1 (CRITICAL: 1)

┌────────────────┬────────────────┬──────────┬──────────┬───────────────────┬───────────────┬────────────────────────────────────────────┐
│    Library     │ Vulnerability  │ Severity │  Status  │ Installed Version │ Fixed Version │                   Title                    │
├────────────────┼────────────────┼──────────┼──────────┼───────────────────┼───────────────┼────────────────────────────────────────────┤
│ linux-libc-dev │ CVE-2023-25775 │ CRITICAL │ affected │ 6.1.38-4          │               │ Improper access control                    │
│                │                │          │          │                   │               │ https://avd.aquasec.com/nvd/cve-2023-25775 │
└────────────────┴────────────────┴──────────┴──────────┴───────────────────┴───────────────┴────────────────────────────────────────────┘
```

I'd say **NOT BAD**. We went from **46 CRITICAL** vulnerabilities to "only" 1.

We can now update the manifest with the new image:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vulnerable-pod
spec:
  containers:
    - name: vulnerable-container
      image: httpd:2.4.57
```

2. **Redeploy the pod with the updated image:**
```bash
kubectl apply -f ./k8s/vulnerable-pod.yaml
```

3. **Verify that the pod is now using the secure image:**
```bash
kubectl get pods
```

---

## Lab Exercise 3: API Security and Secrets Management

### Objective
Learn how to secure Kubernetes API endpoints and manage sensitive information (secrets).

### Task 1: Identify Exposed APIs

1. **Deploy an application with an exposed API endpoint:**

Apply the manifest:

```bash
kubectl apply -f ./k8s/exposed-api.yaml
```

2. **Identify exposed APIs using kube-hunter:**

```bash
kubectl run kube-hunter --image=aquasec/kube-hunter
```

### Task 2: API Authentication and Authorization

1. **Create a ServiceAccount and associated RoleBinding for the API:**


Apply the manifest:

```bash
kubectl apply -f ./k8s/api-rbac.yaml
```

2. **Secure the API's deployment manifest by adding a `serviceAccountName` field:**

```yaml
# exposed-api.yaml
...
spec:
  template:
    spec:
      serviceAccountName: api-service-account
      containers:
        - name: exposed-api-container
          image: httpd:2.4.57
          ports:
            - containerPort: 8080
```

Apply the updated manifest:
```bash
kubectl apply -f ./k8s/exposed-api.yaml
```
