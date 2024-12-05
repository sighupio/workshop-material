# Deploying a multi-tier application

In this chapter we are going to deploy a multi-tier micro-services oriented application called `PowerApp`, the application was built for the purpose of this workshop. The application is composed by a `frontend` in `PHP` served by apache, by a `backend` service in `nodejs` and a `mongodb` database. It's a simple listing application where you just add items to your list and they will get persisted.

## Goal of this section

The end goal of this section is to (obviously) have the application running. In order to achieve that, we will have to deploy all the services with their configurations and secrets. Once that is done, we will need to setup the communication between them.  

The only pod exposed to the outside world is the `frontend`. We will do this in two flavors: via `NodePort` and with an `Ingress`.

First of all, execute the following line:

```bash
kubectl apply -f workshop/namespace-dev.yaml
```

This will create a Namespace named `dev`. We can switch our current context to use this new namespace by default:

```bash
kubectl config set-context --current --namespace dev
```

This way, each time we execute `kubectl` it will operate inside the `dev` namespace.

## Prerequisites: ConfigMaps & Secrets

If you have a look at `workshop/deployment-powerapp-web.yaml` you will see that states the follow:

```yaml
…
env:
  - name: BACKEND_HOST
    value: powerapp-backend-service
  - name: COMPANY
    valueFrom:
      configMapKeyRef:
        key: COMPANY
        name: web
  - name: SOME_PASSWORD
    valueFrom:
      secretKeyRef:
        key: some-password
        name: web
…
```

This means that the deployment depends on both a ConfigMap called `web` and a Secret called `web`.

If we try to issue `kubectl apply -f workshop/deployment-powerapp-web.yaml` without having created the ConfigMap and the Secret beforehand, it will result in a failure.

```bash
kubectl get pods -n dev

NAME                            READY     STATUS                       RESTARTS   AGE
powerapp-web-7c675467d8-727cm   0/1       CreateContainerConfigError   0          1m
powerapp-web-7c675467d8-bl8zv   0/1       CreateContainerConfigError   0          1m
powerapp-web-7c675467d8-fc4rr   0/1       CreateContainerConfigError   0          1m
```

As first step we **must** create our `ConfigMaps` and `Secrets`.

```bash
kubectl apply -f workshop/configmap-web.yaml
configmap "web" created

kubectl apply -f workshop/secret-web.yaml
secret "web" created
kubectl get configmaps -n dev
NAME      DATA      AGE
web       2         15s

kubectl get secrets -n dev
NAME                  TYPE                                  DATA      AGE
default-token-p5g8v   kubernetes.io/service-account-token   3         26s
web                   Opaque                                1         11s
```

## Deploying our applications

We can start rolling out our applications in the following way

```bash
kubectl apply -f workshop/deployment-powerapp-backend.yaml
kubectl apply -f workshop/deployment-powerapp-web.yaml
kubectl apply -f workshop/deployment-powerapp-mongodb.yaml

NAME                                READY     STATUS              RESTARTS   AGE
powerapp-backend-106957089-jcw91    0/1       ContainerCreating   0          1m
powerapp-mongodb-2965042848-blp9z   0/1       ContainerCreating   0          43s
powerapp-web-1507534023-d7dvb       0/1       ContainerCreating   0          2m
powerapp-web-1507534023-nxz6c       0/1       ContainerCreating   0          2m
powerapp-web-1507534023-rndj6       0/1       ContainerCreating   0          2m
```

We will soon see that all the deployments end up correctly **except for mongodb**. 

## What is happening?

If we want to check the status of what is happening in our cluster, we should use:  

`kubectl describe pod <pod_name> -n dev`  
`kubectl describe deployment <deployment_name> -n dev`  
`kubectl rollout status deployment/<deployment_name> -n dev`  

Can you guess why our mongodb won't get running?

## Volumes

Mongodb is failing because we forgot one of its dependencies: `the volume`. One of the characteristics of Kubernetes is that it lets you handle storage in terms of volumes that your pods will claim when they get scheduled. In this specific case, `mongodb` is requiring to have a volume available, which currently does NOT exists.

We can create it:  

`kubectl apply -f workshop/persistentvolumeclaim-powerapp-db-volume.yaml`

Nice! We have all our deployments correctly getting rolled out and if there are no issues we should see the pods soon getting `Running`.

yet, we have no idea if the application is running or not and we have no idea if the containers are seeing each others or not.

## Services

### Web

Now we can start to expose the pods to the outer world and to each others.

Let's start with `web`. As mentioned, this is the only pod that will be reachable from outside the cluster.

```bash
kubectl apply -f workshop/service-powerapp-web-service.yaml
```

Check the service to know the NodePort:

```bash
kubectl get svc powerapp-web-service -n dev

NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
powerapp-web-service       NodePort    10.107.219.83    <none>        80:30424/TCP   4h59m
```

Your output may be different: we did not include a specific `nodePort` inside the Service manifest, so Kubernetes will automatically assign a random, free port to it.

Now you have all the information you need to reach the frontend of the application: browse to `http://<your cluster master ip>:<node port>` to see it.

#### Port forward

`kubectl` lets you also create a temporary tunnel to reach Services that are inside the cluster. This is valid also for ClusterIP services.

You may find this functionality useful to quickly check if everything is in place without having to actually expose an application outside of the cluster.

The syntax is: `kubectl port-forward <service name> <local port>:<service port>`. To create a tunnel for the frontend service, run:

```bash
kubectl port-forward svc/powerapp-web-service 8080:80 -n dev
```

Now visiting `http://<your cluster master ip>:8080` should show the frontend application.

### Backend and DB

You probably have noticed some errors inside the web page of our application. Did you figure out why?

We can now rollout services for `backend` and `mongodb` in a similar way. Once that is done, reloading the frontend page should show no error and magically our application works.

```bash
kubectl apply -f workshop/service-powerapp-backend-service.yaml
kubectl apply -f workshop/service-powerapp-mongodb-service.yaml
```

But what is really happening here? Let's discuss this together.

## Exposing applications via Ingress

So far we have exposed the frontend using either a Service with a NodePort or a tunnel, but accessing the service with the combination `<ip>:<port>` isn't exactly ideal. Time to see something more advanced: `Ingress`.

We can apply the ingress as follows:

```bash
kubectl apply -f  workshop/ingress-web.yaml
```

To access the ingress, edit your local `/etc/hosts` file and add the following line:

```plaintext
<your cluster master ip> web.test.example
```

Now you can open another tab in your browser and reach the address: `http://web.test.example:31080`

## Cleanup

To cleanup everything, you can just remove the namespace:

```bash
kubectl delete ns dev
```

Kubernetes will delete the namespace and every resource that it contains.

Also, remember to reset your context:

```bash
kubectl config set-context --current --namespace default
```
