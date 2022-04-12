# Kustomize

Kustomize is useful when we need to combine multiple manifest files in one single deployment

## Hello World

The hello-world application is composed of only 3 pieces: 
- a deployment
- a service
- a secret

Withing the [kustomization.yaml](hello-world/kustomization.yaml) we define:
- the name of the files of the manifest being deployed
- the namespace of the resources being deployed, which kustomize will assign to all resources
- additional labels to be assigned to all resources
- the dynamic generation of a secret from a [file on disk](hello-world/secret.conf)

To build the hello-world application manifest you can simply use:

```shell
kustomize build hello-world
```

to deploy to your kubernetes cluster instead you can use

```shell
kustomize build hello-world | kubectl apply -f -
```

# Trying changing the secret

If we try to change [secret.conf](hello-world/secret.conf) and then deploy the application again we will see how the deployment is changed:
- we'll have 2 ReplicaSet (2 sets of pods)
- we'll have 2 Secrets

This happens because Kustomize appends to the name of the secret (both in the deployemnt of the secret itself and in the referenced secret in the deployment) the hash of the content of the secret itself. This is usefull because most applications only check configuration files at startup and if we would change the content of the secret without changing its name, Kubernetes would not deploy a new set of pods with the new configuration