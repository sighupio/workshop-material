
# Preparation & Setup

You will need to have a laptop (Windows, Linux or Mac), it is preferred for your machine to have at least 8GB of RAM. This isn't strictly required but highly recommended. Working with VMs and Containers **is** resource intensive, no way to get around it.

This workshop requires that you have the following installed on your machine:
- [Virtualbox](https://www.virtualbox.org/)
- [Minikube](https://github.com/kubernetes/minikube#installation)

In order to speed up the setup process, we also recommend you to download the VMs & containers required during the workshop.

### Setting up Kubectl
Kubectl is the CLI controller app for kubernetes. You will use to interact with all the kubernetes cluster. Therefore it is required to be able to perform *any* task during the workshop.

[Here how to install it](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Setting up Kustomize
Kustomize is needed to ease the handling and the customization of multiple
manifest files.

[Here how to install it](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md)


### Setting up minikube

Minikube is a simple one-node installation of Kubernetes specifically designed to work on your local machine.

Do the following commands to setup the minikube installation:

`minikube start --cpus=4`, this will setup the minikube VM

 # ***Install ARGOCD CLI***
https://argoproj.github.io/argo-cd/cli_installation/
```
brew install argocd
```

# ***Install ARGOCD***
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

```

# *** Creating App with UI***
### Login
- Create port-forward tunnel: ```kubectl port-forward svc/argocd-server -n argocd 8080:443```
- Enter `admin` and initial administrator password
- Click the `+ New App`
- Insert your app the name `<APP_NAME>`, use the project `default`
- Connect the `https://github.com/nikever/kubernetes-hello-app-delivery.git` repo to Argo CD
- For *Destination*, set cluster to `https://kubernetes.default.svc` and namespace to `default`
- Click `Create`
- On Top click `SYNC APP`

# *** Creating App with CLI***
```
argocd login `localhost:8080`
argocd app create `<APP_NAME>` --repo https://github.com/nikever/kubernetes-hello-app-delivery.git --path argocd-helm/nginx --dest-server https://kubernetes.default.svc --dest-namespace default --port-forward-namespace argocd
argocd app sync `<APP_NAME>`
```