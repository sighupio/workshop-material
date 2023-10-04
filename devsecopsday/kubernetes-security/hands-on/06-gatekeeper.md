# Gatekeeper

### **Step 1:** Installation of OPA Gatekeeper

To install OPA Gatekeeper on your Kubernetes cluster, follow these steps:  

1. Launch the following command

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
    ```

2. Verify that Gatekeeper components are running (this may take a few minutes):

    ```bash
    kubectl get pods -n gatekeeper-system
    ```

    You should see the Gatekeeper components in the `gatekeeper-system` namespace.

### **Step 2:** Defining Custom Policies

To define custom policies using Rego language, follow these steps

1. Create a policy definition file (e.g., `namespace-labels.rego`) with your custom policies.  
   Here's an example of a policy that enforces label standards:

    ```rego
        package k8srequiredlabels

        violation[{"msg": msg, "details": {"missing_labels": missing}}] {
          provided := {label | input.review.object.metadata.labels[label]}
          required := {label | label := input.parameters.labels[_]}
          missing := required - provided
          count(missing) > 0
          msg := sprintf("you must provide labels: %v", [missing])
        }
    ```

    This policy ensures that the object kind specified in the `constraint` has a label named `gatekeeper`.

2. Load the policy into OPA Gatekeeper by creating a `ConstraintTemplate` resource:

    ```yaml
    apiVersion: templates.gatekeeper.sh/v1
    kind: ConstraintTemplate
    metadata:
      name: k8srequiredlabels
    spec:
      crd:
        spec:
          names:
            kind: K8sRequiredLabels
          validation:
            # Schema for the `parameters` field
            openAPIV3Schema:
              type: object
              properties:
                labels:
                  type: array
                  items:
                    type: string
      targets:
        - target: admission.k8s.gatekeeper.sh
          rego: |
            package k8srequiredlabels

            violation[{"msg": msg, "details": {"missing_labels": missing}}] {
              provided := {label | input.review.object.metadata.labels[label]}
              required := {label | label := input.parameters.labels[_]}
              missing := required - provided
              count(missing) > 0
              msg := sprintf("you must provide labels: %v", [missing])
            }
    ```

    This file is already available for this workshop as gatekeeper-constraint-template.yaml`.

3. Apply the constraint template to your Kubernetes cluster

    ```bash
    kubectl apply -f hands-on/k8s/gatekeeper-constraint-template.yaml
    ```  

This creates a `ConstraintTemplate` resource that defines our constraint.
### **Step 3:** Applying and Enforcing Policies

To apply and enforce policies using OPA Gatekeeper, follow these steps

1. Create a `K8sRequiredLabels` resource:

    ```yaml
    apiVersion: constraints.gatekeeper.sh/v1beta1
    kind: K8sRequiredLabels
    metadata:
      name: ns-must-have-gk
    spec:
      match:
        kinds:
          - apiGroups: [""]
            kinds: ["Namespace"]
      parameters:
        labels: ["gatekeeper"]
    ```  

    This file is already available for this workshop as `gatekeeper-label-policy.yaml`.

2. Apply the `K8sRequiredLabels` resource to your Kubernetes cluster:

    ```bash
    kubectl apply -f hands-on/k8s/gatekeeper-label-policy.yaml
    ```

    This creates a policy that rejects namespaces without a `gatekeeper` label.

### **Step 4:** Testing Policies and Handling Violations

To test policies and handle policy violations, follow these steps:

1. Create a namespace that violates the policy:  

    ```bash

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Namespace
    metadata:
      name: youshallnotpass
    EOF
    ```  

    This will return the following:  
    ```console
    Error from server (Forbidden): error when creating "STDIN": admission webhook "validation.gatekeeper.sh" denied the request: [ns-must-have-gk] you must provide labels: {"gatekeeper"}
    ```  

    Now create a namespace that does not violate the policy:  

      ```bash

      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      kind: Namespace
      metadata:
        name: thiscanpass
        labels:
          gatekeeper: enabled
      EOF
      ```  

    Output:  
    ```console
    namespace/thiscanpass created
    ```   

<br/>

Congratulations! You have successfully `(almost)` secured a Kubernetes cluster using OPA Gatekeeper.  

>Remember to follow security best practices and regularly update and review your policies to maintain a secure Kubernetes environment.

Continue to [Secrets management](07-secrets-management.md)