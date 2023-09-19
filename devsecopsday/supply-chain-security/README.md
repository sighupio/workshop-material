# SUPPLY CHAIN SECURITY WORKSHOP  

![pipeline](images/sighup-logo.png)

## Welcome to the **`supply chain security workshop`** 🏭 🏗️ 🔗 📦 🔐  
<br/>

In this workshop we are going to talk about **supply chain security**.  
In particular, this repo contains a practical tutorial on how to implement a `secure cloud-native CI/CD pipeline`.  
<br/>

## What is supply chain security ?   
The *Oxford Dictionary* defines supply chain as:  
>"the series of processes involved in the production and supply of goods, from when they are first made, grown, etc. until they are bought or used."  

This definition also applies to **digital supply chain** (or **software supply chain**)  
i.e. the supply chain that concerns digital artifacts (the present workshop applies to this specific form of supply chain).

**Supply chain security** refers to all the activities and controls that aim to enhance the security of the supply chain.  

## Are pipeline and supply chain the same thing ?
Even if these two terms are often used interchangeably, they do not point to the same thing.
- A pipeline (Continuous integration and Continuous deployment) is a specific flow made up by a defined sequence  
of stages or steps, typically from raw materials (code base, software libraries, dependencies) to the final product (deployed application).  
- A supply chain is a broader and more comprehensive system that encompasses all the stages involved in producing and delivering a product or service.  
  
If you like to think schematically, think of a *pipeline* as an instantiated subset of a bigger *supply chain*.



## Requirements

If you want to test the workshop in a local playground, you will need the following tools:  
- [Docker](https://www.docker.com/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Helm](https://helm.sh/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Tekton CLI](https://tekton.dev/docs/cli/)
- [Cosign](https://docs.sigstore.dev/cosign/overview/)



## Hands On
In this tutorial we will implement a CI/CD pipeline with the appropriate security controls embedded in it.

* [First Steps in the Cloud(s)](hands-on/01-first-steps.md)
* [CI/CD Pipelines](hands-on/02-cicd-pipelines.md)
* [Get Your Hands Dirty](hands-on/03-get-your-hands-dirty.md)
* [Tekton](hands-on/04-tekton.md)
* [Tekton Tasks](hands-on/05-tekton-tasks.md)
* [SLSA Framework](hands-on/06-slsa-framework.md)
* [RBAC](hands-on/07-rbac.md)
* [Unleash the Pipeline](hands-on/08-unleash-pipeline.md)
* [Results](hands-on/09-results.md)
* [Secret Manager](hands-on/10-secret-manager.md)
* [Frameworks](hands-on/11-frameworks.md)
* [Conclusions](hands-on/12-conclusions.md)
