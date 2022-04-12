# Question 6 - CronJob

Create a `rooster` CronJob that everyday at `6:00 AM` executes `date; echo chicchirichi`.
You can use the `registry.sighup.io/workshop/busybox` image in the definition.

## Solution

Create `rooster.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: rooster
spec:
  schedule: "0 6 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: rooster
            image: registry.sighup.io/workshop/busybox
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo chicchirichi
          restartPolicy: OnFailure
```

Apply the manifest:

```bash
kubectl apply -f rooster.yaml
```
