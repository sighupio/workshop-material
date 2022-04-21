
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

# ***Setup Registry Credential***
```
export REGISTRY_SERVER=https://index.docker.io/v1/

# Replace `[...]` with the registry username
export REGISTRY_USER=[...]

# Replace `[...]` with the registry password
export REGISTRY_PASS=[...]

# Replace `[...]` with the registry email
export REGISTRY_EMAIL=[...]
```

# ***Install Jenkins***
```
helm repo add jenkinsci https://charts.jenkins.io

helm repo update

helm upgrade --install \
    jenkins jenkinsci/jenkins \
    --namespace jenkins \
    --create-namespace \
    --values jenkins-values.yaml \
    --wait
```
# ***Configure cluster for Jenkins***
```
kubectl --namespace jenkins \
    create secret \
    docker-registry regcred \
    --docker-server $REGISTRY_SERVER \
    --docker-username $REGISTRY_USER \
    --docker-password $REGISTRY_PASS \
    --docker-email $REGISTRY_EMAIL

kubectl apply --filename roles.yaml
```
### Login and change password
- Retrieve the initial administrator password with the ***Command Prompt***: ```kubectl --namespace jenkins get secret jenkins --output jsonpath="{.data.jenkins-admin-password}" | base64 --decode && echo```
- Create port-forward tunnel: ```kubectl port-forward svc/jenkins -n jenkins 8080:8080```
- Goto the Jenkins url: http://localhost:8080
- Enter `admin` and the initial administrator password

# ***Create branch main and test on your repository***

# ***Create a Jenkins pipeline***
### Configure Pipeline
- Goto the Jenkins URL: http://localhost:8080
- Click: New Item
- Enter item name: Pipeline
- Select: Multibranch Pipeline
- Click: OK
- Branch Sources: Git
- Project Repository: https://github.com/nikever/kubernetes-hello-app-delivery.git
- Build Configuration: Jenkinsfile
- Script Path: jenkins-kaniko-kustomize/Jenkinsfile 
- Enable Discard Old Builds
- Click: Save

# IMPORTANT! After save, Jenkins scan branch and build pipeline automatically. Stop build pipeline and trigger it manually.
