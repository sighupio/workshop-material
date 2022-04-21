# Prometheus configuration and recording rules

This folder contains Kubernetes manifests to deploy a Prometheus configuration
to enable service discovery under Kubernetes along with node-exporter and
mongodb-exporter. Finally we also add a recording rule to record CPU
utilisation.


Prometheus configuration snippet for automatic target discovery under
Kubernetes:
```yaml
- job_name: 'kubernetes-endpoints'
  kubernetes_sd_configs:
    - role: endpoints
  relabel_configs:
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
      action: replace
      target_label: __scheme__
      regex: (https?)
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
      action: replace
      target_label: __metrics_path__
      regex: (.+)
    - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
      action: replace
      target_label: __address__
      regex: (.+)(?::\d+);(\d+)
      replacement: $1:$2
    - source_labels: [__meta_kubernetes_service_label_app]
      action: replace
      target_label: job
    - source_labels: [__meta_kubernetes_namespace]
      action: replace
      target_label: kubernetes_namespace
    - source_labels: [__meta_kubernetes_service_name]
      action: replace
      target_label: kubernetes_name
```

It is worth to point out that `node-exporter` is a pod of type `DaemonSet`,
meaning that Kubernetes will make sure that exactly one `node-exporter` is ran
at all times on each node.

To deploy these manifests run the following command
```shell
$ kustomize build . | kubectl apply -f -
```

Now Prometheus will automatically perform target discovery through the
Kubernetes API. Setting the annotation `prometheus.io/scrape` to
`true` on a resource object will be enough to have it appears under Prometheus
scrape targets.
```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: 'true'
  labels:
    app: node-exporter
  name: node-exporter
spec:
  type: NodePort
  ports:
    - name: metrics
      port: 9100
      nodePort: 30910
      targetPort: 9100
      protocol: TCP
  selector:
    app: node-exporter
```

## Exercise: define your own recording rules
Add to `record.rules` a recording rule named
`instance:node_filesystem_utilisation` using `node_filesystem_free_bytes` and
`node_filesystem_size_bytes` metrics to record filesystem utilisation.
