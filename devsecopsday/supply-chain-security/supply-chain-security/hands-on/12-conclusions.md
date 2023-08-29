# CONCLUSIONS


In this workshop, we talked about `Supply Chains Security` and how to add security controls to our `CI/CD pipelines`.


<br/>

To remove the deployed application from the cluster, we can use helm:
```console
helm uninstall helm-deployed
```  

In the end, if you want to clean all the resources simply run:
```console
minikube stop --profile tekton-cluster \
&& minikube delete --profile tekton-cluster
```
<br/>

# Thanks for the attention! 😊 👋