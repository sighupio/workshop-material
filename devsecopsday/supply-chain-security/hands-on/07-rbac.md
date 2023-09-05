# RBAC

We need to set up a bit of *Role Based Access Control* on our cluster in order for our pipeline to work properly.  
Launch the following command to configure RBAC:  
```console
kubectl apply -f hands-on/tekton/clusterrole.yaml \
&& kubectl apply -f hands-on/tekton/serviceaccount.yaml \
&& kubectl create clusterrolebinding service-reader-secrets --clusterrole=service-reader --serviceaccount=default:secret-service-account
```  

Output:
```console
clusterrole.rbac.authorization.k8s.io/service-reader created
serviceaccount/secret-service-account created
clusterrolebinding.rbac.authorization.k8s.io/service-reader-secrets created
```  

`serviceaccount.yaml` specifies a kubernetes [service account](https://kubernetes.io/docs/concepts/security/service-accounts/), this is required for the tasks to be able to read the registry secrets.  
You can inspect the tasks that need it in the `PipelineRun` manifest:  
```yaml
taskRunSpecs:
  - pipelineTaskName: skopeo-copy-to-production
    taskServiceAccountName: secret-service-account
  - pipelineTaskName: helm-install
    taskServiceAccountName: secret-service-account
  - pipelineTaskName: cosign
    taskServiceAccountName: secret-service-account
```  

>To learn more about tekton authentication for tasks read the docs [here](https://tekton.dev/docs/pipelines/auth/).  

`clusterrole.yaml` specifies a kubernetes [cluster role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole), this is required for the tasks to be able to perform operations on the cluster.  
Finally, we create the `service-reader-secrets` [cluster role binding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) to associate the cluster role to the service account.  
Without this operation, the `cosign` task will fail with the following error:  

```console
Error: signing [registry.sighup.io/workshop/app:prod]: getting signer: reading key: checking if secret exists: secrets "signing-secrets" is forbidden: User "system:serviceaccount:default:secret-service-account" cannot get resource "secrets" in API group "" in the namespace "tekton-chains"
main.go:74: error during command execution: signing [registry.sighup.io/workshop/app:prod]: getting signer: reading key: checking if secret exists: secrets "signing-secrets" is forbidden: User "system:serviceaccount:default:secret-service-account" cannot get resource "secrets" in API group "" in the namespace "tekton-chains"
```  

Continue to [Unleash the Pipeline](08-unleash-pipeline.md)
