# Question 22 - Secret Token of Service Account

Create a service account called `luke` in the namespace `default`.
Retrieve the service account token and write the base64 **decoded** token to file `/home/workshop/token`

## Solution

Create the service account:

```bash
kubectl create serviceaccount luke
```

Retrieve the service account name:

```bash
kubectl get secrets | grep luke-token | print 
# luke-token-g9chk 
```

Retrieve the secret content:

```bash
kubectl get secret luke-token-g9chk -o yaml
```

Decode the content under `token: ...` with `base64 --decode`:

```bash
echo -n "ybmZkwzQnF... " | base64 --decode - > /home/workshop/token
```
