## Authorization and authentication

Deploy in your cluster the manifest with the command:

```bash
kubectl create ns debug
kubectl apply -f rbac.yaml
```

Great!
Now you have a serviceAccount that enables you to get, create, list and update deployments in debug namespace!

Exercise: now create a serviceAccount by yourself with the following capabilities:

1. get and list secrets in debug namespace
2. delete pods in default namespace

test if everything is fine using:

```bash
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<serviceAccountName> -n <namespace>
```
For example:
```bash
kubectl auth can-i get pods --as=system:serviceaccount:debug:debug-admin-deployments -n debug

kubectl auth can-i get deployments --as=system:serviceaccount:debug:debug-admin-deployments -n debug
```
