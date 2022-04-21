### Lab Helm 

1. Create Helm Chart named `nginx`
    - Edit `replicas` to `4`
    - Change tag image to `alpine`
1. Install chart
1. Upgrade chart with new image `1.20.1`
1. Uninstall the chart

Important! Do not edit templates!

<details close>
<summary> Solution</summary>
<br>
### Solution

#### 1 - Create and update chart 

```sh
helm create nginx
```
```
#Edit values.yaml
# repository: registry.sighup.io/workshop/nginx
# replicaCount: 4
# tag: "alpine"
```
#### 2 - Install `nginx` 
```
helm install nginx ./nginx
```
#### 3 - Upgrade `nginx` 
```sh
#Edit values.yaml
# tag: "1.20.1"
helm upgrade nginx ./nginx/
```
#### 4 - Delete resources
```sh
helm uninstall nginx
```

