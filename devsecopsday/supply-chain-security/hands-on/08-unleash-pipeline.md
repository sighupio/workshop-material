# UNLEASH THE PIPELINE

We are almost ready to launch our pipeline.  
Create tekton `pipeline` and `pipelinerun` resources (this will automatically start the pipeline run):  
> **Note**
> In order to push and pull from SIGHUP registry you need the credentials.  
> If you want to try this at home use your own registry 😁 (for example you can use the free plan of [Docker Hub](https://hub.docker.com)  

Create the `hands-on/tekton/registry_credentials.yaml` file with this structure:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: registry-creds
  annotations:
    tekton.dev/docker-0: https://registry.sighup.io
type: kubernetes.io/basic-auth
stringData:
  username: <your_registry_username>
  password: <your_registry_password>
```



Now you are good to go!  
> **Note**
> The first time you spin up this environment, the pipeline will take some time to run   
> because our cluster need to pull all the images that are used by the tasks.  

```console
kubectl apply -f hands-on/tekton/registry_credentials.yaml \
&& kubectl apply -f hands-on/tekton/pipeline.yaml \
&& kubectl create -f hands-on/tekton/pipelinerun.yaml
```  

Output:  
```console
secret/registry-creds created
pipeline.tekton.dev/clone-build-push created
pipelinerun.tekton.dev/clone-build-push-run-ztkwf created
```  

Continue to [Results](09-results.md)
