# Kind Cluster
___

kind is a tool for running local Kubernetes clusters using Docker container “nodes”.
kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

### Prerequisites

To follow Kind tutorial, you need:
- **Kind** - Follow installation guide [Kind Official Docs](https://kind.sigs.k8s.io/docs/user/quick-start/).

### Step 1 - Start Kubernetes cluster

```bash
make kind
```

### Step 2.1 - Save kubeconfig

```bash
make kubeconfig
```
### Step 2.2 - Test cluster with kubeconfig
```bash
kubectl --kubeconfig kubeconfig get nodes
```
### Step 3 - Delete Kubernetes cluster
```bash
make kubeconfig
```