## Audit Logs

Let's create an audit policy for our API server to log the following requests:

- From Secret resources, level Metadata
- From "system" userGroups, level RequestResponse

To specify the path for the audit policy within the static pod of the API server, you can set the ```--audit-policy-file``` flag in the API server's manifest file. Here's how you can do it:

```bash
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml #add this line
    - --audit-log-path=/etc/kubernetes/audit/logs/audit.log #
    - --audit-log-maxsize=5
    - --audit-log-maxbackup=1                                    # CHANGE
    - --advertise-address=x.x.x.x
    - --allow-privileged=true
```

To create the audit policy file at /etc/kubernetes/audit/policy.yaml, you can write a YAML file with the specific rules you need. Here’s an example policy that matches the requirements you provided:

```yaml
# /etc/kubernetes/audit/policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:

# log Secret resources audits, level Metadata
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets"]

# log node related audits, level RequestResponse
- level: RequestResponse
  userGroups: ["system:nodes"]

# for everything else don't log anything
- level: None
```


We then need to mount this file inside the API server pod (We need to do the same for mounting the log destination)

```yaml
spec:
  containers:
  - name: kube-apiserver
    # Altri parametri...
    volumeMounts:
    - name: audit-policy-volume
      mountPath: /etc/kubernetes/audit/policy.yaml
      subPath: policy.yaml
      readOnly: true
  volumes:
  - name: audit-policy-volume
    hostPath:
      path: /etc/kubernetes/audit/policy.yaml
      type: File
```

We can then restart the API server. Remember that the API server is a static pod, so we need to remove its definition from the path where the static files are located and then re-add it to that path if we want to restart it.

```bash
cd /etc/kubernetes/manifests/
mv kube-apiserver.yaml ..
watch crictl ps # wait for apiserver gone
mv ../kube-apiserver.yaml .
```

and verify that the logs are correctly written to the path we specified

```bash
cat /etc/kubernetes/audit/logs/audit.log | tail | jq
```

```json
{
  "kind": "Event",
  "apiVersion": "audit.k8s.io/v1",
  "level": "Metadata",
  "auditID": "e598dc9e-fc8b-4213-aee3-0719499ab1bd",
  "stage": "RequestReceived",
  "requestURI": "...",
  "verb": "watch",
  "user": {
    "username": "system:serviceaccount:gatekeeper-system:gatekeeper-admin",
    "uid": "79870838-75a8-479b-ad42-4b7b75bd17a3",
    "groups": [
      "system:serviceaccounts",
      "system:serviceaccounts:gatekeeper-system",
      "system:authenticated"
    ]
  },
  "sourceIPs": [
    "192.168.102.21"
  ],
  "userAgent": "manager/v0.0.0 (linux/amd64) kubernetes/$Format",
  "objectRef": {
    "resource": "secrets",
    "apiVersion": "v1"
  },
  "requestReceivedTimestamp": "2020-09-27T20:01:36.238911Z",
  "stageTimestamp": "2020-09-27T20:01:36.238911Z",
  "annotations": {
    "authentication.k8s.io/legacy-token": "..."
  }
}
```

We're done!
