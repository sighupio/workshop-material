# Domanda #3 - users & RBAC

Create un nuovo utente chiamato `pietro`.

Create la chiave privata di pietro con il seguente comando :

```bash
openssl genrsa -out pietro.key 2048 
```

Create un file `pietro.cnf`:

```text
[ req ]
default_bits = 2048  
prompt = no  
default_md = sha256  
distinguished_name = dn

[ dn ]
CN = pietro 

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always  
basicConstraints=CA:FALSE  
keyUsage=keyEncipherment,dataEncipherment  
extendedKeyUsage=serverAuth,clientAuth
```

```bash
openssl req -config ./pietro.cnf -new -key pietro.key -nodes -out pietro.csr  
```

Utilizzateli per creare la `CertificateSigningRequest` necessaria.

`pietro` dovrà avere i seguenti permessi alla risorsa pods nel namespace `default`:

* list
* get


Una volta creati e associati i permessi corretti, testatelo creando il kubeconfig per l'utente.

### Soluzione :

Creiamo il CertificateSigningRequest:

```bash
cat <<EOF | kubectl apply -f -  
apiVersion: certificates.k8s.io/v1beta1  
kind: CertificateSigningRequest  
metadata:  
  name: pietro-request
spec:  
  groups:
  - system:authenticated
  request: $(cat pietro.csr | base64 | tr -d '\n')
  usages:
  - client auth
EOF
```

Verificare la lista delle csr:

```bash
kubectl get certificatesigningrequest
```

Approviamo la richiesta:

```bash
kubectl certificate approve pietro-request
```

Estraiamo il certificato:

```bash
kubectl get csr pietro-request -o jsonpath='{.status.certificate}' | base64 --decode > pietro.crt  
```

A questo punto possiamo creare l'RBAC richiesto ed associarlo all'utente `pietro` :

```bash
cat <<EOF | kubectl apply -f -  
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pietro
  namespace: default
subjects:
  - kind: User
    name: pietro
roleRef:
  kind: Role
  name: pietro
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pietro
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
EOF
```

Creiamo il kubeconfig per l'utente pietro:

```bash
kubectl config --kubeconfig=config-pietro set-cluster workshop --server=https://$(hostname -I | cut -d ' ' -f 1):6443 --embed-certs=true --certificate-authority=/etc/kubernetes/pki/ca.crt  
kubectl config --kubeconfig=config-pietro set-credentials pietro --client-certificate=$(pwd)/pietro.crt --client-key=$(pwd)/pietro.key --embed-certs=true
```

Settiamo il context in cui vogliamo agire:

```bash
kubectl config --kubeconfig=config-pietro set-context workshop --cluster=workshop --user=pietro  
kubectl config --kubeconfig=config-pietro use-context workshop
```

Verifichiamo ora i permessi del nuovo utente:

```bash
kubectl --kubeconfig=config-pietro get pods
```

Verifichiamo di non poter eseguire per esempio un get dei namespace:

```bash
kubectl --kubeconfig=config-pietro get ns
```

Dovremmo ricevere un errore simile al seguente: `Error from server (Forbidden): namespaces is forbidden: User "pietro" cannot list resource "namespaces" in API group "" at the cluster scope`