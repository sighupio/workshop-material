# Monitoring with Prometheus

This folder contains Kubernetes manifests to deploy a monitoring stack composed
by Prometheus, Alertmanager and Grafana in the `monitoring` namespace.

Before deploying, let's see what's inside of `kustomization.yaml`.

To deploy the monitoring stack, run the following command
```shell
$ kustomize build . | kubectl apply -f -
```

This is also a very concrete example of usage for `ConfigMaps` as we use them to
store Prometheus, Alertmanager and Grafana configuration files, the Configmap
are then mounted as a `volume` and the configurations are made available to
the pods as a mounted file.

## Prometheus

The `prometheus` deployment is not yet configured to perform target discovery
through the Kubernetes API.

The `prometheus` service is of type `NodePort`, therefore you can access it on
port `30990` like the following
```shell
$ IP=$(minikube ip)
$ curl http://${IP}:30990/-/ready
Prometheus is Ready.
$ curl http://${IP}:30990/-/healthy
Prometheus is Healthy.
```

This is also a very concrete example of usage for Kubernetes RBAC, because we
need to give Prometheus access to a list of resources in order for service
discovery to work. See [prometheus-rbac.yaml](prometheus-rbac.yaml) for details.

## Grafana

The `grafana` deployment is already configured with Prometheus as datasource and
to automatically load dashboards definitions from
`/grafana-dashboard-definitions/0`. You will find a "Kubernetes Nodes" dashboard
already provisioned to play with.

The `grafana` service is of type `NodePort`, you can access it on port `30300`
with `admin` as username and password .

## Alertmanager

The `alertmanager` service is of type `NodePort`, you can access it on port
`30993`.
