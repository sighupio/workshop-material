# Question 5 - Job

Create a namespace `red`.

Create a job called `red` in the `red` namespace.
The job should run the image `registry.sighup.io/workshop/busybox` and execute `sleep 2 && echo done`.
The job should run 10 times and execute at most 3 runs in parallel.

Check the jobs log when terminated.

## Solution

Create the `red` namespace:

```bash
kubectl create ns red
```

Create `job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: red
  namespace: red
spec:
  completions: 10
  parallelism: 3
  template:
    spec: 
      restartPolicy: Never
      containers: 
      - name: red-container
        image: registry.sighup.io/workshop/busybox
        command:
        - sh
        - -c
        - sleep 2 && echo done
```

Apply the manifest:

```bash
kubectl apply -f job.yaml
```
