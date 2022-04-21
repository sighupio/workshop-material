## Purpose

This is an example of how to build a kube-like controller with a single type.

## Running

**Prerequisite**: Since the sample-controller uses `apps/v1` deployments, the Kubernetes cluster version should be greater than 1.9.

```sh
# assumes you have a working kubeconfig, not required if operating in-cluster
go build -o pizza-controller .
./pizza-controller -kubeconfig=$HOME/.kube/config

# create a CustomResourceDefinition
kubectl create -f manifests/crd.yaml

# create a custom resource of type Pizza
kubectl create -f manifests/pizza.yaml

# check pizza crd and deployment created through the custom resource
kubectl get pizza
kubectl get deployments
```