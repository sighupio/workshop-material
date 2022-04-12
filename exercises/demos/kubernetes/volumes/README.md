### Question - Storage 

1. Create a persistent volume claim `alpha-claim` in the namespace default with:

    - storageClass: `local-path`
    - access mode: `ReadWriteOnce`
    - Capacity: `1Gi`

1. Create a pod called `volume-user` that uses the image `registry.sighup.io/workshop/nginx:alpine` that mounts this volume on `/usr/share/nginx/html`.

1. Enter the pod `volume-user` and create a file `index.html` inside the mounted directory with arbitrary content.

1. Delete and recreate the pod

1. Check that the file `/usr/share/nginx/html/index.html` inside the pod is still present.


<details close>
<summary> Solution</summary>
<br>
### Solution

- [Dynamic Provisioning K8s docs](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/#using-dynamic-provisioning)

#### 1 - Create PVC

```sh
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: alpha-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
```

#### 2 - Create POD

```sh
apiVersion: v1
kind: Pod
metadata:
  name: volume-user
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: alpha-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
```

#### 3 - Create index.html file

```sh
kubectl exec -it volume-user -- bash 
root@volume-user:/# touch /usr/share/nginx/html/index.html
root@volume-user:/# echo 'hello' > /usr/share/nginx/html/index.html
exit
kubectl exec -it volume-user -- cat /usr/share/nginx/html/index.html
```

#### 4 - Delete, recreate and check

```sh
kubectl delete pod volume-user
kubectl apply -f pod.yaml
kubectl exec -it volume-user -- cat /usr/share/nginx/html/index.html
```