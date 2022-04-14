# Minikube demo cluster
___

### Prerequisites

To follow Vagrant tutorial, you need:
- **Minikube** - Follow installation guide on https://minikube.sigs.k8s.io/docs/start/ to install Minikube

### Start Kubernetes  cluster


```bash

make minikube   
```

By default it creates a cluster with the following parameters:

```bash
minikube start \
    --driver virtualbox \
    --kubernetes-version v1.21.2 \
    --cni cilium \
    --memory 2048 \
    --cpus 2
```

You can change any of the parameters setting the appropriate variable:

```bash
# Change version to 1.20.2
make minikube kubernetes-version=v1.20.2

# Change version to 1.18.14
make minikube kubernetes-version=1.18.14

# Increase memory and cpu
make minikube memory=4096 cpu=4
```

Enable addons via:

```bash
make addons
# enables ingress and metrics servers add-ons
```

Clean up:

```bash
make delete
```
