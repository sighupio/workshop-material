# Logging

This folder contains Kubernetes manifests to deploy a logging stack composed by
Fluentd, Elasticsearch and Kibana in the `logging` namespace.

Before deploying, let's see what's inside of `kustomization.yaml`.

To deploy the logging stack, run the following command
```shell
kustomize build . | kubectl apply -f -
```

Note that both Fluentd and Elasticsearch export metrics that Prometheus will
automatically pick up once we deploy them.

## Fluentd

Fluentd is deployed as a `DaemonSet` to make sure that logs collection will
automatically happen on every node.

## Elasticsearch

Elasticsearch is deployed as a `StatefulSet` because each pod needs to provision
its own storage and to maintain a stable name across reloads. This is needed
especially if we want to have an highly-available Elasticsearch deployment.

The `elasticsearch` service is of type `NodePort`, you can access it on port
`30920`.

## Kibana

Kibana is deployed to automatically connect to the Elasticsearch instance.

The `kibana` service is of type `NodePort`, you can access it on port `30561`.
