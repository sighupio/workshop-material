# Commands

Preview template:

```bash
helm template test hello-app
```

Deploy staging:

```bash
helm install staging hello-app --namespace helm-staging --values values-staging.yaml --create-namespace
```

Deploy prod:

```bash
helm install prod hello-app --namespace helm-prod --values values-prod.yaml --create-namespace
```

Update staging (Update chart)

```bash
helm upgrade staging hello-app --namespace helm-staging --values values-staging.yaml --create-namespace
```

```bash
helm history staging -n helm-staging
```
