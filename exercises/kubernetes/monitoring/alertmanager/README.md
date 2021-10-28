# Alertmanager

This folder containers Kubernetes manifests to deploy a Prometheus alert that
will trigger when the CPU utilisation is above 90% percent for at least one
minute and a `Job` to trigger this alert.

Example Alertmanager configuration:
```yaml
global:
  smtp_smarthost: 'mail.example.com:587'
  smtp_from: 'support@example.com'
  smtp_auth_username: 'support@example.com'
  smtp_auth_password: 'XXXXXXXX'
  smtp_require_tls: true
  slack_api_url: "https://hooks.slack.com/services/XXXXXXXX"
  resolve_timeout: 5m
templates:
  - '/etc/alertmanager/config/*.tmpl'
route:
  group_by: ['alertname', 'job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'alert-team'
  routes:
    - match:
        alertname: HeartBeat
      group_wait: 30s
      group_interval: 1m
      repeat_interval: 1m
      receiver: 'healthchecks'
    - match:
        severity: critical
      receiver: 'pager-team'
      continue: true
    - match:
        kubernetes_namespace: 'prod-powerapp'
      receiver: 'powerapp-team'
      continue: true
    - match_re:
        alertname: '.*'
      receiver: 'alert-team'
receivers:
  - name: 'alert-team'
    slack_configs:
      - channel: kubernetes-alerts
        send_resolved: true
    email_configs:
      - to: 'kubernetes-alerts@example.com'
        send_resolved: true
  - name: 'powerapp-team'
    slack_configs:
      - channel: powerapp-alerts
        send_resolved: true
  - name: 'pager-team'
    pagerduty_configs:
      - routing_key: XXXXXXXX
        send_resolved: true
        severity: '{{ if .CommonLabels.severity }}{{ .CommonLabels.severity | toLower }}{{ else }}critical{{ end }}'
  - name: 'healthchecks'
    webhook_configs:
      - url: 'https://hc-ping.com/XXXXXXXX'
```

To deploy the alert rules:
```shell
$ kustomize build . | kubectl apply -f -
```

Now, let's trigger the `NodeHighCpuUtilisation` alert
```shell
$ kubectl apply -f stress-test.yaml
```

## Exercise: define your own alert
Add to `alert.rules` a `NodeHighMemoryUtilisation` alert that will trigger if
the memory utilisation is above 80% for at least one minute. Once you have added
such an alert, try to trigger it modifyng the `stress-test` job.
