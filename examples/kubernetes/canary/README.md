# Canary deployment

In this exercise we're going to see how canary deployments work in Kubernetes using only its primitives.

1. Let's create our deploy and expose it with a NodePort service. Be sure to examine the manifests first!

    ```bash
    kubectl apply -f deploy-v1.yaml
    kubectl apply -f service-v1.yaml
    ```

2. You can now call the application using localhost on port `30080`:

    ```bash
    curl localhost:30080
    ```

3. We want to change the image from `httpd:alpine` to `nginx:alpine`.

    The switch should not happen fast or automatically, but using the Canary approach:

    - 20% of requests should hit the new image
    - 80% of requests should hit the old image

    Let's create a new deployment definition, with the following requirements:

    - name: `beautiful-v2`
    - image: `nginx:alpine`
    - labels: `app=beautiful`
    - total number of pods between `v1` and `v2`: `10`

    Find out how many replicas do you need, based on the canary percentages.
    You also need to change the number of replicas of the `v1` deployment.

    Let's apply the changes to our cluster, waiting for all the pods to be running.

    > You can use the `v1` definition and change it accordingly, but be sure not to delete the `v1` deployment!

4. You can try to call the application again, let's say 20 times.

    ```bash
    for i in `seq 1 20`; do curl -s localhost:30080 | grep h1; done
    ```

    You should expect to have about 4 responses from the new pods and 16 from the old ones.

5. Finally, you can cleanup everything.

    ```bash
    kubectl delete deployment beautiful-v1 beautiful-v2
    kubectl delete service beautiful
    ```
