# Gatekeeper

### **Step 1:** Installation of OPA Gatekeeper

To install OPA Gatekeeper on your Kubernetes cluster, follow these steps

1. Launch the following command

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
    ```

2. Verify that Gatekeeper components are running:

    ```bash
    kubectl get pods -n gatekeeper-system
    ```

    You should see the Gatekeeper components in the `gatekeeper-system` namespace.

### **Step 2:** Defining Custom Policies

To define custom policies using Rego language, follow these steps

1. Create a policy definition file (e.g., `pod-security.rego`) with your custom policies. Here's an example of a policy that enforces Pod security standards:

    ```rego
    package k8s.pod.security

    violation[{"msg": msg, "details": {"missing_fields": missing}}] {
      container := input.spec.containers[_]
      not container.securityContext.runAsNonRoot
      msg := "Containers must not run as root"
      missing := {"securityContext.runAsNonRoot": true}
    }

    violation[{"msg": msg, "details": {"missing_fields": missing}}] {
      container := input.spec.initContainers[_]
      not container.securityContext.runAsNonRoot
      msg := "Init containers must not run as root"
      missing := {"securityContext.runAsNonRoot": true}
    }
    ```

    This policy ensures that containers and init containers do not run as the root user.

2. Load the policy into OPA Gatekeeper by creating a `ConstraintTemplate` resource:

    ```yaml
    apiVersion: templates.gatekeeper.sh/v1beta1
    kind: ConstraintTemplate
    metadata:
      name: podsecuritypolicy
    spec:
      crd:
        spec:
          names:
            kind: PodSecurityPolicy
      targets:
        - target: admission.k8s.gatekeeper.sh
          rego: |
            package k8s.pod.security

            violation[{"msg": msg, "details": {"missing_fields": missing}}] {
              container := input.parameters.containers[_]
              not container.securityContext.runAsNonRoot
              msg := "Containers must not run as root"
              missing := {"securityContext.runAsNonRoot": true}
            }

            violation[{"msg": msg, "details": {"missing_fields": missing}}] {
              container := input.parameters.initContainers[_]
              not container.securityContext.runAsNonRoot
              msg := "Init containers must not run as root"
              missing := {"securityContext.runAsNonRoot": true}
            }
    ```

    This file is already available for this workshop as gatekeeper-constraint-template.yaml`.

3. Apply the constraint template to your Kubernetes cluster

    ```bash
    kubectl apply -f hands-on/k8s/gatekeeper-constraint-template.yaml
    ```  

This creates a `ConstraintTemplate` resource that defines the constraints for Pod security.
### **Step 3:** Applying and Enforcing Policies

To apply and enforce policies using OPA Gatekeeper, follow these steps

1. Create a `PodSecurityPolicy` resource that references the `pod-security` constraint template:

    ```yaml
    apiVersion: constraints.gatekeeper.sh/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: disallow-root-containers
    spec:
      match:
        kinds:
          - kinds: ["Pod"]
      parameters:
        containers:
          - name: container
            description: "Container spec"
            required: true
            schema:
              type: object
              properties:
                securityContext:
                  type: object
                  properties:
                    runAsNonRoot:
                      type: boolean
    ```  

    This file is already available for this workshop as `gatekeeper-pod-security-policy.yaml`.

2. Apply the `PodSecurityPolicy` resource to your Kubernetes cluster:

    ```bash
    kubectl apply -f hands-on/k8s/gatekeeper-pod-security-policy.yaml
    ```

    This creates a policy that disallows containers running as the root user.

### **Step 4:** Testing Policies and Handling Violations

To test policies and handle policy violations, follow these steps:

1. Create a Pod resource that violates the policy:  

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: gatekeeper-test-pod
    spec:
      containers:
        - name: my-container
          image: nginx
          securityContext:
            runAsNonRoot: false  # not permitted !!!
    ```

    This file is already available for this workshop as `gatekeeper-test-pod.yaml`.  
2. Attempt to create the Pod:  

    ```bash
    kubectl apply -f hands-on/k8s/gatekeeper-test-pod.yaml
    ```

    The creation of the Pod should fail, and you will receive an error message indicating the policy violation:

    ```bash
    Error from server (Forbidden): error when creating "hands-on/k8s/gatekeeper-test-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [disallow-root-containers] Containers must not run as root
    ```  

Congratulations! You have successfully `(almost)` secured a Kubernetes cluster using OPA Gatekeeper.  

>Remember to follow security best practices and regularly update and review your policies to maintain a secure Kubernetes environment.

Continue to [Secrets management](08-secrets-management.md)