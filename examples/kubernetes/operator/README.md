# Kubernetes Operator

In this exercise we're going to see how operators work in Kubernetes by deploying [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator).

1. Download the manifests

    ```bash
    wget https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/heads/main/kustomization.yaml
    wget https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/heads/main/bundle.yaml
    ```

2. Create a `monitoring` namespace

    ```bash
    kubectl create namespace monitoring
    ```

3. Deploy the operator and its CRDs

    ```bash
    kustomize edit set namespace monitoring && kubectl create -k .
    ```

4. Check the new installed CRDs and the prometheus-operator pod:

    ```bash
    kubectl get pod -n monitoring
    ```

    ```bash
    kubectl get crd | grep monitoring
    ```

5. Now we can create, for example, a resource with `kind: Prometheus`. Let's try it out!

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      namespace: monitoring
      name: prometheus
    ---
    apiVersion: monitoring.coreos.com/v1
    kind: Prometheus
    metadata:
      name: prometheus
      namespace: monitoring
    spec:
      serviceAccountName: prometheus
    EOF
    ```

    ```bash
    kubectl get prometheus -n monitoring
    ```

6. The logic is fully handled by the Operator, so you just have to wait some time, and you will find a new pod in `monitoring` namespace.

    ```bash
    kubectl get pod -n monitoring -w
    ```

    If you have a closer look at the resources in `monitoring` namespace, you will also find `configmaps`, `secrets`, `services` and the `statefulset` that our pod is part of.
    And all of these resources were created by the Operator, without you caring about them!

7. Let's clean the environment up.

    ```bash
    kubectl delete prometheus prometheus -n monitoring
    kubectl delete sa prometheus -n monitoring
    kustomize edit set namespace monitoring && kubectl delete -k .
    ```
