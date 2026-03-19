# ConfigMaps and Secrets in Pods

A good practice when writing applications is to separate application code from configuration. ConfigMaps and Secrets let you employ this patterns with Kubernetes.

## The basics

Conceptually a ConfigMap is just a set of `key-value` pairs.

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key.

Kubernetes automatically creates secrets which contain credentials for accessing the API and it automatically modifies your pods to use this type of secret.

Secrets are stored as binaries in etcd and automatically encoded/decoded to base64 when retrieved.

## How to create a ConfigMap

You can create a ConfigMap by CLI:

`kubectl create configmap example-configmap --from-file=game-properties-file-name=game.properties`

or by `yaml` file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-configmap
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

### Retrieving ConfigMaps

To display all currently available configmaps in the `default` namespace: `kubectl get configmap`
To get the related yaml file: `kubectl get configmap game-configmap -o yaml`

## How to create a secret

You can create a secret by CLI:

`kubectl create secret generic db-user-pass --from-literal=username=admin --from-literal=password=1f2d1e2e67df`

or by `yaml` file:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4= # echo -n "admin" | base64
  password: MWYyZDFlMmU2N2Rm # echo -n "1f2d1e2e67df" | base64
```

### Retrieving Secrets

To display all currently available Secrets in the `default` namespace: `kubectl get secret`
To get the related yaml file: `kubectl get secret <configmap-name> -o yaml`

## Consuming ConfigMaps and Secrets

There are two ways of consuming a ConfigMap:  

1. Environment variables
2. File in a volume

They are stored as strings in etcd as clear text, you should NOT put sensitive data in ConfigMaps. If you need to specify such information, use Secrets.

You can use both in a Kubernetes workload, such as:

```yaml
apiVersion: apps/v1 # Version of the Kubernetes API to use, necessary for kubectl
kind: Deployment
metadata:
  name: imaginarygame # Name referenced during the deployment life
spec:
  replicas: 3 # Desired state ensured by rs
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels: # Labels (simple key-values) associated with the pod
        app: nginx
    spec:
      containers:
      - name: game-container
        image: registry.sighup.io/workshop/nginx
        env:
        # consume the property-like keys in environment variables
        - name: GAME_PROPERTIES_NAME
          valueFrom:
            configMapKeyRef:
              name: game-configmap
              key: game-properties-file-name
        - name: UI_PROPERTIES_NAME
          valueFrom:
            configMapKeyRef:
              name: game-configmap
              key: ui-properties-file-name
        envFrom:
        # consume a ConfigMap to mount all its keys as environment variables
          - configMapRef:
              name: web-env
        volumeMounts:
        - name: config-volume
          mountPath: /etc/game
        - name: secret-volume
          mountPath: /etc/game-secrets
      volumes:
      # consume the file-like keys of the configmap via volume plugin
      - name: config-volume
        configMap:
          name: game-configmap
          items:
          - key: ui.properties
            path: cfg/ui.properties
          - key: game.properties
            path: cfg/game.properties
      # consume an entire secret as a volume
      - name: secret-volume
        secret:
          secretName: mysecret
```

Let's deploy and check all resources:

```bash
kubectl apply -f example-app/cm.yaml
kubectl apply -f example-app/web-env.yaml
kubectl apply -f example-app/secret.yaml

kubectl get configmap
kubectl get secret
```

Let's deploy and check deployment:

```bash
kubectl apply -f example-app/deploy.yaml
kubectl describe deploy imaginarygame
```

Let's check environment variables and files mounted:

```bash
kubectl exec -it imaginarygame-c587857bf-mrxzd -- env
kubectl exec -it imaginarygame-c587857bf-mrxzd -- ls /etc/game/cfg
kubectl exec -it imaginarygame-c587857bf-mrxzd -- ls /etc/game-secrets
```

Let's clean:

```bash
kubectl delete -f configmaps/cm.yaml -f example-app/secret.yaml -f example-app/web-env.yaml -f configmaps/deploy.yaml
```
