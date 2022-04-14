### Storage 

1. Create a persistent volume claim `alpha-claim` in the namespace default with:

    - storageClass: `local-path`
    - access mode: `ReadWriteOnce`
    - Capacity: `1Gi`

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
or
```sh
kubectl apply -f pvc.yaml
```
<br>

2. Create a pod called `volume-user` that uses the image `registry.sighup.io/workshop/nginx:alpine` that mounts this volume on `/usr/share/nginx/html`.

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
or
```sh
kubectl apply -f pod.yaml
```
3. Enter the pod `volume-user` and create a file `index.html` inside the mounted directory with arbitrary content.

```sh
kubectl exec -it volume-user -- bash 

root@volume-user:/# touch /usr/share/nginx/html/index.html
root@volume-user:/# echo 'hello' > /usr/share/nginx/html/index.html
exit

kubectl exec -it volume-user -- cat /usr/share/nginx/html/index.html
```

4. Delete and recreate the pod

```sh
kubectl delete pod volume-user
kubectl apply -f pod.yaml
kubectl exec -it volume-user -- cat /usr/share/nginx/html/index.html
```

5. Check that the file `/usr/share/nginx/html/index.html` inside the pod is still present.


- [Dynamic Provisioning K8s docs](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/#using-dynamic-provisioning)
