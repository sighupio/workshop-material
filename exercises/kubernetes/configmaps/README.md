# ConfigMaps

A good practice when writing applications is to separate application code from configuration. ConfigMaps let's you employ this patterns with Kubernetes.

## The basics

Conceptually a ConfigMap is just a set of `key-value` pairs.

## Defining 

They can be configured in a `ConfigMap.yaml` file.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-configmap
data:
  # property-like keys
  game-properties-file-name: game.properties
  ui-properties-file-name: ui.properties

  # file-like keys
  game.properties: |
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30
  ui.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice
```

Or they can be configured using `kubectl`:

```bash
kubectl create configmap my-config \
     --from-literal=literal-key=literal-value \
     --from-file=ui.properties \
     --from-file=path/to/config/dir
```

### Retrieving ConfigMaps

To display all currently available configmaps: `kubectl get configmap <configmap-name>`  
To get the related yaml file: `kubectl get configmap <configmap-name> -o yaml`


## Consuming ConfigMaps

There are two ways of consuming a ConfigMap:  
1. Environment variables
2. File in a volume

```yaml
apiVersion: apps/v1
 kind: Deployment
 …
    spec:
      containers:
      - name: game-container
        image: imaginarygame
        command: [ "game-server", "--config-dir=/etc/game/cfg" ]
        env:
        # consume the property-like keys in environment variables
        - name: GAME_PROPERTIES_NAME
          valueFrom:
            configMapKeyRef:
              name: example-configmap
              key: game-properties-file-name
        - name: UI_PROPERTIES_NAME
          valueFrom:
            configMapKeyRef:
              name: example-configmap
              key: ui-properties-file-name
        volumeMounts:
        - name: config-volume
          mountPath: /etc/game
      volumes:
      # consume the file-like keys of the configmap via volume plugin
      - name: config-volume
        configMap:
          name: example-configmap
          items:
          - key: ui.properties
            path: cfg/ui.properties
          - key: game.properties
            path: cfg/game.properties
```

They are stored as strings in etcd as clear text, you should NOT put sensitive data in configmaps.
