### Lab Kustomize 

1. Create a deployment `hello-app` with image `gcr.io/google-samples/hello-app:1.0` and manage `dev` and `prod` environment:
    - `dev` image is `gcr.io/google-samples/hello-app:2.0`
    - Edit replicas in `prod` env from 1 to 3

<details close>
<summary> Solution</summary>
<br>
### Solution

#### 1 - Look `8-kustomize/kustomize` folder

```sh
kustomize build dev | kubectl apply -f -
kustomize build production | kubectl apply -f -
```
#### 2 - Delete resources
```sh
kustomize build dev | kubectl delete -f -
kustomize build production | kubectl delete -f -
```
