AppArmor is an optional kernel module and Kubernetes feature, so verify it is supported on your Nodes before proceeding:

1. Verify that the AppArmor kernel module is enabled on the relevant node

```bash
cat /sys/module/apparmor/parameters/enabled
```

You should expect a

```bash
Y
```

The kubelet verifies that AppArmor is enabled on the host before admitting a pod with AppArmor explicitly configured.

2. Verify that the AppArmor profile you want to use is present on the node

```bash
sudo cat /sys/kernel/security/apparmor/profiles | sort
```

## Creating an AppArmor Profile

```C
#include <tunables/global>

profile k8s-apparmor-example-deny-write flags=(attach_disconnected) {
  #include <abstractions/base>

  file,

  # Deny all file writes.
  deny /** w,
}
```

This profile denies any write actions within the container.

To load the AppArmor profile on the relevant node, you can use the following command:

```bash
sudo apparmor_parser -q [path_to_profile]
```

Next, you can create a pod that uses the AppArmor profile you just created:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-apparmor
spec:
  securityContext:
    appArmorProfile:
      type: Localhost
      localhostProfile: k8s-apparmor-example-deny-write
  containers:
  - name: hello
    image: busybox:1.28
    command: [ "sh", "-c", "echo 'Hello AppArmor!' && sleep 1h" ]
```

Now you can create the pod that uses the profile:

```bash
kubectl apply -f [file_name]
```

To verify that the container is using the correct AppArmor profile, you can use the following command:

```bash
kubectl exec hello-apparmor -- cat /proc/1/attr/current
```

The output should be 

```bash
k8s-apparmor-example-deny-write (enforce)
```

Finally, you can see what happens if you violate the profile by writing to a file:

```bash
kubectl exec hello-apparmor -- touch /tmp/test
```

```bash
touch: /tmp/test: Permission denied
error: error executing remote command: command terminated with non-zero exit code: Error executing in Docker Container: 1
```