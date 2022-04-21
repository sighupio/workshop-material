[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

# SIGHUP Training Exercises

<p align="center">
  <img width="120" src="./logos/kubernetes-cka-color.png">
  <img width="120" src="./logos/kubernetes-security-specialist-color.png">
  <img width="120" src="./logos/kubernetes-ckad-color.png">
</p>

A curated collection of exercises to prepare you as Kubernetes black belt!
With this exercise and demos you will have a good understanding and implementation of Kubernetes eco-system. What matters is that you enjoy the learning process.

<!-- ABOUT THE REPO -->
## About The Repo

This repository will contain a list of hands-on exercises and demos for you to attempt and up skill yourself.

___

### Prerequisites

This tutorial assumes some basic prerequisite, you need:

- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [Helm](https://helm.sh/docs/intro/install/)


## :small_blue_diamond: 1. Cluster Setup
Curated list of local Kubernetes Clusters
#### Kind

<details>
<summary>Quickstart - Read more</summary>
<br>

```bash
cd cluster-setup/kind
make kind
```

More information about the setup can be found [here](kind/).

More information about [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/).

</details>
<br>

- [X] [Play with Kind](cluster-setup/kind)

#### Minikube
<details>
<summary>Quickstart - Read more</summary>
<br>

```bash
cd cluster-setup/minikube
make minikube   
```

More information about the setup can be found [here](minikube/).

More information about [Minikube](https://minikube.sigs.k8s.io/docs/start/).

</details>
<br>

- [X] [Play with Minikube](cluster-setup/minikube)

#### Vagrant
<details>
<summary>Quickstart - Read more</summary>
<br>

```bash
cd cluster-setup/vagrant
make vagrant
```

More information about the setup can be found [here](vagrant/).

More information about [Vagrant](https://learn.hashicorp.com/collections/vagrant/getting-started).

</details>
<br>

- [X] [Play with Minikube](cluster-setup/minikube)

#### Free Kubernetes Online Environment
- [Killer Coda](https://killercoda.com/playgrounds)

## :small_blue_diamond: 2. Exercises
Learning Kubernetes can seem challenging. But fear not! Here's a curated list of delightful set of hands-on labs that covers from the Fundamentals to Certified!

#### :large_orange_diamond: Examples
This type of exercises will guide you step by step in understanding the various aspects of the technologies.

##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  :white_circle: Docker
- [X] [PowerApp by SIGHUP](exercises/docker)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; :white_circle: Kubernetes
- [X] [Play with cluster](exercises/kubernetes/play-with-cluster)
- [X] [Deployments](exercises/kubernetes/deployments)
- [X] [ConfigMaps](exercises/kubernetes/configmaps)
- [X] [Secrets](exercises/kubernetes/secrets)
- [X] [Jobs](exercises/kubernetes/jobs)
- [ ] [Services](exercises/kubernetes/services)
- [X] [Storage](exercises/kubernetes/volumes)
- [X] [Multi Tier App](exercises/kubernetes/power-app)
- [X] [RBAC](exercises/kubernetes/rbac)
- [X] [Network Policies](exercises/kubernetes/network-policy)
- [X] [Kustomize](exercises/kubernetes/kustomize)
- [X] [Kustomize multi Env](exercises/kubernetes/kustomize-2)
- [X] [Helm](exercises/kubernetes/helm)
- [X] [Helm](exercises/kubernetes/helm-2)
- [X] [Etcd](exercises/kubernetes/etcd)
- [X] [CRD](exercises/kubernetes/crd)
- [X] [Debug and Troubleshooting](exercises/kubernetes/debug-troubleshooting)
- [X] [Jenkins Kaniko Kustomize](exercises/kubernetes/jenkins-kaniko-kustomize)
- [X] [ArgoCD with Helm](exercises/kubernetes/argocd-helm)
- [X] [Logging](exercises/kubernetes/logging)
- [ ] [Monitoring](exercises/kubernetes/monitoring)
<br>

> ⚠️ **This repo is still quite new and we are working on adding as many learning resources and projects as possible, so please do bear with us**