# Blue-green deployment

In this exercise we're going to see how blue-green deployments work in Kubernetes using only its primitives.

1. Let's create our deploy and expose it with a NodePort service. Be sure to examine the manifests first!

    ```bash
    kubectl apply -f deploy-v1.yaml
    kubectl apply -f service-v1.yaml
    ```

2. You can now call the application using localhost on port `30080`:

    ```bash
    curl localhost:30080
    ```

3. We want to change the image from `httpd:alpine` to `nginx:alpine`, and we want this change to happen instantly.

    Let's create a new deployment definition, with the following requirements:

    - name: `beautiful-v2`
    - image: `nginx:alpine`
    - replicas: `4`
    - labels: `app=beautiful,version=v2`

    And let's also apply it to our cluster, waiting for all the pods to be running.

    > You can use the `v1` definition and change it accordingly, but be sure not to delete the `v1` deployment!

4. You can try to call the application again and get the same response as before.

    ```bash
    curl localhost:30080
    ```

    Why is that? Well, because our Service is still routing traffic to the `v1` application!

5. So, let's update the service definition.

    Change the Service selector from `version=v1` to `version=v2`.

    > You can use the `kubectl edit` command or edit the manifest and apply it again.

6. Let's call the application one last time.

    ```bash
    curl localhost:30080
    ```

    What is the response? Has it changed?

7. We don't need the `v1` deployment anymore, let's scale it down.

    ```bash
    kubectl scale deploy beautiful-v1 --replicas=0
    ```

8. Finally, you can cleanup everything.

    ```bash
    kubectl delete deployment beautiful-v1 beautiful-v2
    kubectl delete service beautiful
    ```
