# Secrets Management in Kubernetes

Secrets management is a crucial aspect of Kubernetes security.  
In this workshop, we will explore how to create, update, and retrieve secrets in Kubernetes, as well as discuss the challenges associated with securing secrets and the benefits of using RBAC configurations, secret managers, and sealed secrets.

## Creating a Secret

To create a secret in Kubernetes, you can use the `kubectl` command-line tool or define the secret in a manifest file.  
Let's look at an example of creating a secret to store a database password.

### Using `kubectl`:

```bash
kubectl create secret generic db-secret --from-literal=password=secretpassword
```


### Using a manifest file (`db-secret.yaml`)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  password: c2VjcmV0cGFzc3dvcmQ=  # base64-encoded "secretpassword"
```



To create the secret from the manifest file:

```bash
kubectl apply -f db-secret.yaml
```


## Updating a Secret

To update a secret in Kubernetes, you can use the `kubectl` command-line tool or modify the secret's manifest file.

### Using `kubectl`

```bash
kubectl create secret generic db-secret --from-literal=password=newpassword --dry-run=client -o yaml | kubectl apply -f -
```


### Updating the manifest file (`db-secret.yaml`):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  password: bmV3cGFzc3dvcmQ=  # base64-encoded "newpassword"
```

To update the secret from the modified manifest file:

```bash
kubectl apply -f db-secret.yaml
```

## Retrieving a Secret

To retrieve a secret in Kubernetes, you can use the `kubectl` command-line tool or access the secret within a pod.

### Using `kubectl`

```bash
kubectl get secret db-secret
kubectl get secret db-secret -o yaml
kubectl get secret db-secret -o json
```

### Accessing the secret within a pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-access-pod
spec:
  containers:
    - name: secret-container
      image: nginx
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
```

In the example above, the secret `db-secret` is accessed by setting the environment variable `DB_PASSWORD` with the value of the `password` key in the secret.  
Apply the previous manifest:  
```bash
kubectl apply -f hands-on/k8s/pod-with-secret.yaml
```  

Once the pod is up and running, retrieve the secret from the pod environment variables:  
```bash
kubectl exec -it secret-access-pod -- env | grep DB_PASSWORD

DB_PASSWORD=newpassword
```  


## Challenges with Kubernetes Secrets

Kubernetes secrets, although useful for storing sensitive information, have certain security challenges:  
1. **Access Control** : By default, any user with access to the cluster can view and modify secrets, which can pose a security risk if not properly controlled.  
2. **Encryption** : Kubernetes secrets are base64-encoded, which is an encoding rather than encryption.  
   Base64-encoded secrets can be easily decoded if an attacker gains unauthorized access.  
3. **Auditing** : Kubernetes does not provide built-in auditing capabilities for secret access and modification, making it challenging to track and investigate unauthorized activities.  
## Proper RBAC Configuration and Secret Managers

To enhance the security of secrets in Kubernetes, it is essential to implement proper Role-Based Access Control (RBAC) configurations and consider using external secret management solutions or secret managers. Here are some reasons why:  
1. **Granular Access Control** : By configuring RBAC, you can define fine-grained access controls to secrets, ensuring that only authorized users or services can view or modify them.  
2. **Encryption and Key Management** : Secret managers, such as [HashiCorp Vault](https://www.vaultproject.io/) and [CyberArk Conjur](https://www.conjur.org/), provide stronger encryption mechanisms and centralized key management, making secrets less vulnerable to unauthorized access.  
3. **Auditing and Compliance** : Secret managers often offer auditing capabilities, allowing you to track who accessed secrets and when.  
   This helps meet compliance requirements and aids in identifying potential security breaches.  
## Sealed Secrets

[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) is a Kubernetes-native solution that addresses the security concerns with storing secrets directly in the cluster.  
Sealed Secrets uses asymmetric cryptography to encrypt secrets, which can only be decrypted by a specific controller running in the cluster.  

Sealed Secrets work as follows:  
1. The Sealed Secrets controller is installed in the cluster, along with a public key that can be used for encryption.  
2. To create a sealed secret, you generate an encrypted version of the secret using the public key and store it in the cluster.  
3. The Sealed Secrets controller, running in the cluster, is responsible for decrypting the sealed secrets and creating the actual secrets.  

Using Sealed Secrets provides an extra layer of security by encrypting secrets using public-key cryptography, eliminating the need for direct access to the unencrypted secret data.  
## Conclusion

Securing secrets in Kubernetes is crucial for maintaining the integrity and confidentiality of sensitive information.  
By implementing proper *RBAC configurations*, leveraging secret managers like *HashiCorp Vault* or *CyberArk Conjur*, and considering solutions like *Sealed Secrets*  
you can significantly enhance the security of your Kubernetes cluster and protect your secrets from unauthorized access and potential breaches.

<br/>

Continue to [OWASP Top 10](09-owasp-top-10.md)