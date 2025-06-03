Admission controllers are a mechanism employed by Kubernetes to allow administrators to enforce some policies on requests passed to the API server.
For example, the [`AlwaysPullImages`](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages) admission controller sets the `imagePullPolicy` to `Always`, even if specified otherwise in the `Pod` manifest.

# Objective
Set-up the `AlwaysPullImages` admission controller.

# Steps
## Ensure we can specify the Image Pull Policy
Run an nginx Pod with the following:
```bash
kubectl run test1 --image=alpine --image-pull-policy=IfNotPresent -- sleep 3600
```

Then check what's inside the actual object manifest by running
```bash
kubectl get pod test1 -oyaml | yq '.spec.containers[0].imagePullPolicy'
# It should return IfNotPresent
```

## Backup the `kube-apiserver.yaml` file
```bash
cp /etc/kubernetes/manifests/kube-apiserver.yaml ~/kube-apiserver.yaml.bak
```

## Ensure the AdmissionController directive is present
In the control plane node, open the `/etc/kubernetes/manifests/kube-apiserver.yaml` static pod manifest and make sure the following line is present.
```yaml
# ...
  args:
  - kube-apiserver
  # - ...
  - --enable-admission-plugin=...
# ...
```

## Add the AlwaysPullImages AdmissionController
Edit the `/etc/kubernetes/manifests/kube-apiserver.yaml` static pod manifest to include the `AlwaysPullImages` AdmissionController.

```yaml
# ...
  args:
  - kube-apiserver
  # - ...
  - --enable-admission-plugin=AlwaysPullImages,...
# ...
```

## Wait for the API server to come back
```bash
watch kubectl get nodes
```

## Create a Pod with the `IfNotPresent` image pull policy
Run an nginx Pod with the following:
```bash
kubectl run test2 --image=alpine --image-pull-policy=IfNotPresent -- sleep 3600
```

Then check what's inside the actual object manifest by running
```bash
kubectl get pod test2 -oyaml | yq '.spec.containers[0].imagePullPolicy'
# It should return Always
```

## Restore the API server backupAdd commentMore actions
```bash
cp ~/kube-apiserver.yaml.bak /etc/kubernetes/manifests/kube-apiserver.yaml 
```

## Wait for the API server to come back
```bash
watch kubectl get nodes
```
