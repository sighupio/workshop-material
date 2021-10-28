# Kubernetes

Quickly setup a demo Kubernetes cluster in various environments:

|  Cluster   |         Folder         |
| ---------- | ---------------------- |
| `minikube` | [minikube/](minikube/) |
| `kind`     | [kind/](kind/)         |
| `vagrant`  | [vagrant/](vagrant/)   |

## Quickstart

### Minikube

```bash
cd minikube
make minikube   
```

More information about the setup can be found [here](minikube/).

More information about [Minikube](https://minikube.sigs.k8s.io/docs/start/).

### Kind

```bash
cd kind
make kind
```

More information about the setup can be found [here](kind/).

More information about [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/).

### Vagrant

```bash
cd vagrant
make vagrant
```

More information about the setup can be found [here](vagrant/).

More information about [Vagrant](https://learn.hashicorp.com/collections/vagrant/getting-started).
