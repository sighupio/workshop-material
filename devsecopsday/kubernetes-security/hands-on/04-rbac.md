# RBAC

## Kubeconfig

The Kubeconfig file is a configuration file used by Kubernetes for authentication and authorization purposes, providing access to a cluster.  
It contains information such as cluster details, authentication methods, and user permissions through Role-Based Access Control (RBAC).  

The Kubeconfig file is typically located in the user's home directory under the path `~/.kube/config`.  

To retrieve the current context and user from the Kubeconfig file, you can use the following command:

```bash
kubectl config current-context
kubectl config view --minify --output 'jsonpath={..user}'
```  

The first command retrieves the current context name, and the second command retrieves the current user (`client-certificate` & `client-key` tuple) associated with that context.
>In Kubernetes, a context is a combination of cluster, user, and namespace settings that determines the target for the current Kubernetes configuration. It provides a way to switch between different Kubernetes clusters and user identities easily.

Kubeconfig example:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/sighup/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Tue, 27 Jun 2023 15:20:39 CEST
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: cluster_info
    server: https://127.0.0.1:50472
  name: k8s-security-cluster
contexts:
- context:
    cluster: k8s-security-cluster
    extensions:
    - extension:
        last-update: Tue, 27 Jun 2023 15:20:39 CEST
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: context_info
    namespace: default
    user: k8s-security-cluster
  name: k8s-security-cluster
current-context: k8s-security-cluster
kind: Config
preferences: {}
users:
- name: k8s-security-cluster
  user:
    client-certificate: /Users/sighup/.minikube/profiles/k8s-security-cluster/client.crt
    client-key: /Users/sighup/.minikube/profiles/k8s-security-cluster/client.key
```  

## RBAC

Create a new namespace in the cluster:

```bash
kubectl create namespace my-namespace
```

Define RBAC roles and role bindings to grant or restrict access to resources within the namespace.  
Create a YAML manifest file (e.g., rbac.yaml) with the RBAC configuration:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-role
  namespace: my-namespace
rules:
  - apiGroups: [""]
    resources: ["pods", "services"]
    verbs: ["get", "list", "create", "update", "delete"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-role-binding
  namespace: my-namespace
subjects:
  - kind: User
    name: user1
roleRef:
  kind: Role
  name: my-role
  apiGroup: rbac.authorization.k8s.io

```  

This example creates a role named my-role that allows users assigned to it to perform actions on pods and services within the namespace.  
The my-role-binding binds the role to user1.  

Apply the RBAC configuration to the namespace:

```bash
kubectl apply -f hands-on/k8s/rbac.yaml
```

Verify that the access controls are working as expected. For example, try listing pods in the namespace as user1:

```bash
kubectl auth can-i list pods -n my-namespace --as user1
```  

What happens if you try the same thing but for the `default` namespace?  

## Creating and Managing ServiceAccounts

### **Step 1:** Understanding the Role of ServiceAccounts

Before we dive into creating and managing ServiceAccounts, let's understand their purpose and functionality within a Kubernetes cluster:

- ServiceAccounts are bound to namespaces and allow fine-grained control over access permissions.
- They provide a mechanism for pods to authenticate themselves and interact securely with the Kubernetes API server.
- ServiceAccounts are associated with a set of secrets that are used to authenticate the ServiceAccount and provide credentials for accessing other resources.

## Step 2: Creating a ServiceAccount:  
1. Open your terminal and connect to your Kubernetes cluster. 
2. To create a ServiceAccount, use the following command:

    ```console
    kubectl create serviceaccount my-serviceaccount
    ```  

### **Step 3:** Assigning Roles and Permissions to a ServiceAccount

1. To grant roles and permissions to the ServiceAccount, you need to create a Role or ClusterRole and a RoleBinding or ClusterRoleBinding.
    - A Role or ClusterRole defines a set of permissions.
    - A RoleBinding or ClusterRoleBinding binds the Role or ClusterRole to the ServiceAccount.
2. Create a Role or ClusterRole using a YAML file.  

    ```yaml
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: my-new-role
    rules:
    - apiGroups: [""]
      resources: ["pods"]
      verbs: ["get", "list", "watch"]
    ```  

    Apply the previous manifest

    ```bash
    kubectl apply -f hands-on/k8s/role.yaml
    ```  

3. Create a RoleBinding or ClusterRoleBinding using a YAML file

    ```yaml
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: my-new-rolebinding
    subjects:
    - kind: ServiceAccount
      name: my-serviceaccount
    roleRef:
      kind: Role
      name: my-new-role
      apiGroup: rbac.authorization.k8s.io
    ```

    Apply the previous manifest:  
    ```bash
    kubectl apply -f hands-on/k8s/rolebinding.yaml
    ```  


### **Step 4:** Using a ServiceAccount in a Pod

To utilize the created ServiceAccount within a pod:

1. Define the `serviceAccountName` field in the pod's specification. For example, modify an existing pod's YAML file as follows:

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: my-pod
    spec:
      serviceAccountName: my-serviceaccount
      containers:
      - name: my-container
        image: my-image
    ```

    Apply the previous manifest:

    ```bash
    kubectl apply -f hands-on/k8s/pod-nginx.yaml
    ```  


### **Step 5:** Verifying ServiceAccount Authentication

1. To verify that the pod is authenticating using the ServiceAccount, execute the following command (once the pod is up and running):  

    ```bash
    kubectl exec -it my-pod -- sh
    ```

2. Within the shell session of the pod, run the following command:

    ```bash
    curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes/api/v1/namespaces/default/pods
    ```  

    Output:
    <details>
    <summary><b>Click to expand!</b></summary>

    ```json
    {
      "kind": "PodList",
      "apiVersion": "v1",
      "metadata": {
        "resourceVersion": "1406"
      },
      "items": [
        {
          "metadata": {
            "name": "my-pod",
            "namespace": "default",
            "uid": "5a62fc19-eaf8-4556-92e2-d6ac0cfdde68",
            "resourceVersion": "1183",
            "creationTimestamp": "2023-06-27T12:10:15Z",
            "annotations": {
              "cni.projectcalico.org/containerID": "1100772c156905fbd879a26c5d18530a6ab4996f47f9cc90713c23dfc6710202",
              "cni.projectcalico.org/podIP": "10.244.20.69/32",
              "cni.projectcalico.org/podIPs": "10.244.20.69/32",
              "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{},\"name\":\"my-pod\",\"namespace\":\"default\"},\"spec\":{\"containers\":[{\"image\":\"nginx:latest\",\"name\":\"my-container\",\"ports\":[{\"containerPort\":80}]}],\"serviceAccountName\":\"my-serviceaccount\"}}\n"
            },
            "managedFields": [
              {
                "manager": "kubectl-client-side-apply",
                "operation": "Update",
                "apiVersion": "v1",
                "time": "2023-06-27T12:10:15Z",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                  "f:metadata": {
                    "f:annotations": {
                      ".": {},
                      "f:kubectl.kubernetes.io/last-applied-configuration": {}
                    }
                  },
                  "f:spec": {
                    "f:containers": {
                      "k:{\"name\":\"my-container\"}": {
                        ".": {},
                        "f:image": {},
                        "f:imagePullPolicy": {},
                        "f:name": {},
                        "f:ports": {
                          ".": {},
                          "k:{\"containerPort\":80,\"protocol\":\"TCP\"}": {
                            ".": {},
                            "f:containerPort": {},
                            "f:protocol": {}
                          }
                        },
                        "f:resources": {},
                        "f:terminationMessagePath": {},
                        "f:terminationMessagePolicy": {}
                      }
                    },
                    "f:dnsPolicy": {},
                    "f:enableServiceLinks": {},
                    "f:restartPolicy": {},
                    "f:schedulerName": {},
                    "f:securityContext": {},
                    "f:serviceAccount": {},
                    "f:serviceAccountName": {},
                    "f:terminationGracePeriodSeconds": {}
                  }
                }
              },
              {
                "manager": "calico",
                "operation": "Update",
                "apiVersion": "v1",
                "time": "2023-06-27T12:10:16Z",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                  "f:metadata": {
                    "f:annotations": {
                      "f:cni.projectcalico.org/containerID": {},
                      "f:cni.projectcalico.org/podIP": {},
                      "f:cni.projectcalico.org/podIPs": {}
                    }
                  }
                },
                "subresource": "status"
              },
              {
                "manager": "kubelet",
                "operation": "Update",
                "apiVersion": "v1",
                "time": "2023-06-27T12:10:53Z",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                  "f:status": {
                    "f:conditions": {
                      "k:{\"type\":\"ContainersReady\"}": {
                        ".": {},
                        "f:lastProbeTime": {},
                        "f:lastTransitionTime": {},
                        "f:status": {},
                        "f:type": {}
                      },
                      "k:{\"type\":\"Initialized\"}": {
                        ".": {},
                        "f:lastProbeTime": {},
                        "f:lastTransitionTime": {},
                        "f:status": {},
                        "f:type": {}
                      },
                      "k:{\"type\":\"Ready\"}": {
                        ".": {},
                        "f:lastProbeTime": {},
                        "f:lastTransitionTime": {},
                        "f:status": {},
                        "f:type": {}
                      }
                    },
                    "f:containerStatuses": {},
                    "f:hostIP": {},
                    "f:phase": {},
                    "f:podIP": {},
                    "f:podIPs": {
                      ".": {},
                      "k:{\"ip\":\"10.244.20.69\"}": {
                        ".": {},
                        "f:ip": {}
                      }
                    },
                    "f:startTime": {}
                  }
                },
                "subresource": "status"
              }
            ]
          },
          "spec": {
            "volumes": [
              {
                "name": "kube-api-access-fhnqf",
                "projected": {
                  "sources": [
                    {
                      "serviceAccountToken": {
                        "expirationSeconds": 3607,
                        "path": "token"
                      }
                    },
                    {
                      "configMap": {
                        "name": "kube-root-ca.crt",
                        "items": [
                          {
                            "key": "ca.crt",
                            "path": "ca.crt"
                          }
                        ]
                      }
                    },
                    {
                      "downwardAPI": {
                        "items": [
                          {
                            "path": "namespace",
                            "fieldRef": {
                              "apiVersion": "v1",
                              "fieldPath": "metadata.namespace"
                            }
                          }
                        ]
                      }
                    }
                  ],
                  "defaultMode": 420
                }
              }
            ],
            "containers": [
              {
                "name": "my-container",
                "image": "nginx:latest",
                "ports": [
                  {
                    "containerPort": 80,
                    "protocol": "TCP"
                  }
                ],
                "resources": {},
                "volumeMounts": [
                  {
                    "name": "kube-api-access-fhnqf",
                    "readOnly": true,
                    "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount"
                  }
                ],
                "terminationMessagePath": "/dev/termination-log",
                "terminationMessagePolicy": "File",
                "imagePullPolicy": "Always"
              }
            ],
            "restartPolicy": "Always",
            "terminationGracePeriodSeconds": 30,
            "dnsPolicy": "ClusterFirst",
            "serviceAccountName": "my-serviceaccount",
            "serviceAccount": "my-serviceaccount",
            "nodeName": "k8s-security-cluster",
            "securityContext": {},
            "schedulerName": "default-scheduler",
            "tolerations": [
              {
                "key": "node.kubernetes.io/not-ready",
                "operator": "Exists",
                "effect": "NoExecute",
                "tolerationSeconds": 300
              },
              {
                "key": "node.kubernetes.io/unreachable",
                "operator": "Exists",
                "effect": "NoExecute",
                "tolerationSeconds": 300
              }
            ],
            "priority": 0,
            "enableServiceLinks": true,
            "preemptionPolicy": "PreemptLowerPriority"
          },
          "status": {
            "phase": "Running",
            "conditions": [
              {
                "type": "Initialized",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2023-06-27T12:10:15Z"
              },
              {
                "type": "Ready",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2023-06-27T12:10:53Z"
              },
              {
                "type": "ContainersReady",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2023-06-27T12:10:53Z"
              },
              {
                "type": "PodScheduled",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2023-06-27T12:10:15Z"
              }
            ],
            "hostIP": "192.168.49.2",
            "podIP": "10.244.20.69",
            "podIPs": [
              {
                "ip": "10.244.20.69"
              }
            ],
            "startTime": "2023-06-27T12:10:15Z",
            "containerStatuses": [
              {
                "name": "my-container",
                "state": {
                  "running": {
                    "startedAt": "2023-06-27T12:10:52Z"
                  }
                },
                "lastState": {},
                "ready": true,
                "restartCount": 0,
                "image": "nginx:latest",
                "imageID": "docker-pullable://nginx@sha256:593dac25b7733ffb7afe1a72649a43e574778bf025ad60514ef40f6b5d606247",
                "containerID": "docker://a34e24975fcf51b69612c115921af5ea911c6cbc8a37c0e4c19a0e7ffc7a090e",
                "started": true
              }
            ],
            "qosClass": "BestEffort"
          }
        }
      ]
    }
    ```  
    </details>
    <br/>

This command retrieves a list of pods in the default namespace using the token provided by the ServiceAccount.  

>QUESTION: What happens now if I try to retrieve the pods list at the cluster scope with the following command?

```bash
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc.cluster.local/api/v1/pods
```

Continue to [Networking](05-networking.md)
