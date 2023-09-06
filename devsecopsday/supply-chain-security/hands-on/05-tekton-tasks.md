# TEKTON TASKS

When implementing pipelines via `Tekton` we have extreme freedom and flexibility of action.  
We could very well create custom tasks for each pipeline step but, as always, we don't necessarily have to reinvent the wheel.  
[Tekton Hub](https://hub.tekton.dev/) contains a collection of *community-maintained* tasks that can be very handy when you need to design pipelines.  

We are going to download some tasks from *tekton hub* via the *tekton cli*, copy and run the following command:  
```console
tkn hub install task git-clone \
&& tkn hub install task check-make \
&& tkn hub install task markdown-lint \
&& tkn hub install task gitleaks \
&& tkn hub install task pylint \
&& tkn hub install task python-coverage \
&& tkn hub install task hadolint \
&& tkn hub install task kube-linter \
&& tkn hub install task helm-conftest \
&& tkn hub install task conftest \
&& tkn hub install task kaniko \
&& tkn hub install task trivy-scanner \
&& tkn hub install task skopeo-copy \
&& tkn hub install task helm-upgrade-from-source
```  

If not specified, the tekton cli will install the latest version of our required tasks.  
Output:
```console
Task git-clone(0.9) installed in default namespace
Task check-make(0.1) installed in default namespace
Task markdown-lint(0.1) installed in default namespace
Task gitleaks(0.1) installed in default namespace
Task pylint(0.3) installed in default namespace
Task python-coverage(0.1) installed in default namespace
Task hadolint(0.1) installed in default namespace
Task kube-linter(0.1) installed in default namespace
Task helm-conftest(0.1) installed in default namespace
Task conftest(0.1) installed in default namespace
Task kaniko(0.6) installed in default namespace
Task trivy-scanner(0.2) installed in default namespace
Task skopeo-copy(0.2) installed in default namespace
Task helm-upgrade-from-source(0.3) installed in default namespace
```  

Apart from these, in order to explore the anatomy of a tekton task, we will create a custom one from scratch.  
The task in question will take care of signing our OCI image with [cosign](https://docs.sigstore.dev/cosign/overview/).  
Before starting, it is necessary to make the premise that, as in any kubernetes native framework  
tekton make uses of a descriptive approach in which the runtime entities are defined via yaml manifest.  

<br/>

Inspect the `tekton/cosign-custom.yaml` file:  
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: cosign
spec:
  params:
    - name: IMAGE
      description: The image to sign
  steps:
    - name: sign-result
      image: bitnami/cosign:2.2.0
      script: |
        yes | cosign sign --key k8s://tekton-chains/signing-secrets "$(params.IMAGE)"
      securityContext:
        runAsUser: 0
```  
Here we can observe what a tekton task specification looks like.  
This task pull the `bitnami/cosign:2.2.0` image and use it to sign our image.  
we'll come back to it later to dive into some details, including how this task uses secrets to connect to the docker registry.  

Apply the cosign task manifest and the custom skopeo task:  
```console
kubectl apply -f hands-on/tekton/cosign-custom.yaml && kubectl apply -f hands-on/tekton/skopeo-custom-task.yaml

```  

Finally, we need to apply the manifest of another custom task that we will inspect in detail in the final part of this workshop:
```console
kubectl apply -f hands-on/tekton/secret-manager.yaml

task.tekton.dev/secret-manager created
```  

Continue to [SLSA Framework](06-slsa-framework.md)
