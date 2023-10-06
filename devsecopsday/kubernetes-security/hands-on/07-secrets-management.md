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

To create the secret from the manifest file:

```bash
kubectl create -f ./k8s/db-secret.yaml
```


You can also check the content by running:

```bash
kubectl get secret db-secret -o jsonpath='{.data.password}'
```

Or even decode the base64:

```bash
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 --decode
```


## Updating a Secret

To update a secret in Kubernetes, you can use the `kubectl` command-line tool or modify the secret's manifest file.

### Using `kubectl`

```bash
kubectl create secret generic db-secret --from-literal=password=newpassword --dry-run=client -o yaml | kubectl apply -f -
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

## CyberArk Conjur

### Deploy a Conjur Follower

1. Retrieve the Conjur Cluster certificate and deploy a ConfigMap containing the certicate.

```bash
export conjurdns=ec2-54-216-156-83.eu-west-1.compute.amazonaws.com
```

```bash
# Set the clustername completing it with your name and surname, eg: conjur-follower-workshop-lucabandini
export clustername=conjur-follower-workshop-<namesurname>
```

```bash
openssl s_client -showcerts -connect $conjurdns:443 < /dev/null 2> /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > conjur.pem
```

Deploy the ConfigMap:

```yaml
apiVersion: v1
data:
  ssl-certificate: |
    # conjur.pem content
kind: ConfigMap
metadata:
  name: conjur-cm
  namespace: cyberark-conjur

```

2. Link the ClusterRole with the ServiceAccount (already deployed)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: conjur-authn-role
rules:
- apiGroups: [""]
  resources: ["pods", "serviceaccounts"]
  verbs: ["get", "list"]
- apiGroups: ["extensions"]
  resources: [ "deployments", "replicasets"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: [ "deployments", "statefulsets", "replicasets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create", "get"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: conjur-authn-rolebinding
  namespace: conjur-follower
subjects:
- kind: ServiceAccount
  name: authn-k8s-sa
  namespace: conjur-follower
roleRef:
  kind: ClusterRole
  name: conjur-authn-role
  apiGroup: rbac.authorization.k8s.io
```

3. Deploy the Conjur Follower

Edit the `k8s/conjur-follower-deploy.yaml` setting the correct follower name

```yaml
# [...]
          - name: CONJUR_AUTHN_LOGIN
            value: host/conjur/authn-k8s/conjur-follower-workshop-<namesurname>/apps/seed-fetcher-app
# [...]
          - name: CONJUR_AUTHENTICATORS
            value: authn-k8s/conjur-follower-workshop-<namesurname>
        ports:
# [...]
```

Complete the onboarding procedure by populating the authenticator variables on Conjur.

Install Conjur CLI:

```bash
pip install conjur
```

Login to Conjur:

```bash
conjur init -s --url https://ec2-54-216-156-83.eu-west-1.compute.amazonaws.com && conjur -i admin -p PasswordSighup02!
```

Populate the variables:

```bash
export TOKEN_SECRET_NAME="$(kubectl get secrets -n cyberark-conjur \
| grep 'authn-k8s-sa.*service-account-token' \
| head -n1 \
| awk '{print $1}')"

kubectl get secret $TOKEN_SECRET_NAME -n cyberark-conjur \
--output='go-template={{ .data.token }}' \
| base64 -D > sa_token.txt

kubectl config view --raw --minify --flatten \
--output='jsonpath={.clusters[].cluster.server}' > k8_api_url.txt

conjur variable values add conjur/authn-k8s/${clustername}/kubernetes/ca-cert "$(cat conjur.pem)"

conjur variable values add conjur/authn-k8s/${clustername}/kubernetes/service-account-token "$(cat sa_token.txt)"

conjur variable values add conjur/authn-k8s/${clustername}/kubernetes/api-url "$(cat k8_api_url.txt)"

```

And then deploy it with `kubectl apply -f k8s/conjur-follower-deploy`

---


5. Deploy a demo-app

```bash
export CONJUR_SSL_CERTIFICATE=conjur.pem
export CONJUR_AUTHN_TOKEN_FILE=/run/conjur/access-token
export CONJUR_APPLIANCE_URL=https://${conjurdns}
export CONJUR_AUTHN_URL=$CONJUR_APPLIANCE_URL/authn-k8s/${clustername}
export CONJUR_ACCOUNT=$(curl -k $CONJUR_APPLIANCE_URL/info | jq -r '.configuration.conjur.account')
```

```bash
kubectl create configmap demo-app-cm -n demo-app \
  -o yaml \
  --dry-run \
  --from-literal CONJUR_ACCOUNT=${CONJUR_ACCOUNT} \
  --from-literal CONJUR_AUTHN_TOKEN_FILE=${CONJUR_AUTHN_TOKEN_FILE} \
  --from-literal CONJUR_APPLIANCE_URL=${CONJUR_APPLIANCE_URL} \
  --from-literal CONJUR_AUTHN_URL=${CONJUR_AUTHN_URL} \
  --from-file "CONJUR_SSL_CERTIFICATE=${CONJUR_SSL_CERTIFICATE}" | kubectl apply -f -
```

Deploy the demo-app:

```bash
kubectl apply -f hands-on/demo-app-conjur.yaml
```

## Conclusion

Securing secrets in Kubernetes is crucial for maintaining the integrity and confidentiality of sensitive information.  
By implementing proper *RBAC configurations*, leveraging secret managers like *HashiCorp Vault* or *CyberArk Conjur*, and considering solutions like *Sealed Secrets*  
you can significantly enhance the security of your Kubernetes cluster and protect your secrets from unauthorized access and potential breaches.

<br/>

Continue to [OWASP Top 10](09-owasp-top-10.md)