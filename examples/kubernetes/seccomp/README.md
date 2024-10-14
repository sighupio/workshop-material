# Seccomp

In this exercise we're going to create some Seccomp profiles and use them in pods.

1. Create the folder and the 3 profiles

```bash
mkdir -p /var/lib/kubelet/seccomp/profiles
cd /var/lib/kubelet/seccomp
curl -L -o profiles/audit.json https://k8s.io/examples/pods/security/seccomp/profiles/audit.json
curl -L -o profiles/violation.json https://k8s.io/examples/pods/security/seccomp/profiles/violation.json
curl -L -o profiles/fine-grained.json https://k8s.io/examples/pods/security/seccomp/profiles/fine-grained.json
ls profiles
cd ~
```

2. Create a pod that uses the default Container Runtime seccomp profile. This should be running without any issues.

```bash
kubectl apply -f default-pod.yaml

kubectl get pod default-pod

```

3. Create a pod that uses a seccomp profile for syscall auditing. Also, create a service to expose it.

> Before applying the manifest, please replace <node_name> with a node that has seccomp configured.

```bash
kubectl apply -f audit-pod.yaml

# Since the NodePort is 32321 on all Kubernetes nodes, we can call it from our master node as well.
curl localhost:32321

```

Now you can inspect the node's syslog to actually display the audit logs.

```bash
tail -f /var/log/syslog | grep 'http-echo'
```

4. Create a pod that uses a seccomp profile that causes violation.

> Before applying the manifest, please replace <node_name> with a node that has seccomp configured.

```bash
kubectl apply -f violation-pod.yaml

kubectl get pod violation-pod
```

Here seccomp has been instructed to error on any syscall by setting "defaultAction": "SCMP_ACT_ERRNO". This is extremely secure, but removes the ability to do anything meaningful. What you really want is to give workloads only the privileges they need.

5. Create a pod with a fine-grained seccomp profile

> Before applying the manifest, please replace <node_name> with a node that has seccomp configured.

```bash
kubectl apply -f fine-pod.yaml

kubectl get pod fine-pod

# Since the NodePort is 32322 on all Kubernetes nodes, we can call it from our master node as well.
curl localhost:32322

```

You should see no output in the syslog. This is because the profile allowed all necessary syscalls and specified that an error should occur if one outside of the list is invoked. This is an ideal situation from a security perspective, but required some effort in analyzing the program.

