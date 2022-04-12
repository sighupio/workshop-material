# Domanda #4 - kubectl outputs

Estraete la definizione in `yaml` del nodo master e salvatela in `/opt/outputs/master.yaml`

### Soluzione :

```
$ kubectl get node master -o yaml > /opt/outputs/master.yaml
```

Estraete poi la stessa definizione in `json` e salvatela in `/opt/outputs/master.json`

### Soluzione :

```
$ kubectl get node master -o json > /opt/outputs/master.json
```

