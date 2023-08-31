# OWASP TOP 10

## Lab Exercise 1: Container Image Security

### Objective
Learn how to secure container images and prevent common vulnerabilities in Kubernetes deployments.

### Task 1: Identify Vulnerable Images

1. **Deploy a Kubernetes Pod using a vulnerable container image:**

Apply the manifest:
```bash
kubectl apply -f ./k8s/vulnerable-pod.yaml
```

2. **Verify that the pod is running:**
```bash
kubectl get pods
```

### Task 2: Implement Image Scanning

1. **Integrate Trivy into your cluster:**
```bash
kubectl apply -f https://github.com/aquasecurity/trivy/release/latest/trivy-crd.yaml
kubectl apply -f https://github.com/aquasecurity/trivy/release/latest/trivy-standalone.yaml
```

2. **Scan the vulnerable image:**

```bash
kubectl trivy vulnerability report webgoat/webgoat-8.0:latest
```

3. **Discuss the vulnerabilities found and their potential impacts.**

### Task 3: Remediate Vulnerabilities

1. **Update the vulnerable container image in `vulnerable-pod.yaml` to a secure version.**

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
          image: <your-api-image:version>
          ports:
            - containerPort: 8080
```

Apply the updated manifest:
```bash
kubectl apply -f ./k8s/exposed-api.yaml
```

### Task 3: Secrets Management

1. **Create a secret containing sensitive data:**
```bash
kubectl create secret generic api-secrets --from-literal=api-key=your-api-key
```

2. **Modify the API deployment to use the secret:**

```yaml
# exposed-api.yaml
...
spec:
  template:
    spec:
      serviceAccountName: api-service-account
      containers:
        - name: exposed-api-container
          image: <your-api-image:version>
          env:
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: api-secrets
                  key: api-key
          ports:
            - containerPort: 8080
```

Apply the updated manifest:

```bash
kubectl apply -f ./k8s/exposed-api.yaml
```