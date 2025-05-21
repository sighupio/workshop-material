# Install gVisor
In this exercise we will install gVisor, install a `RuntimeClass` for it, and use to deploy a sandboxed Pod.

gVisor is a security mechanism used to sandbox workloads. It does so by intercepting all system calls made by the Pod and handles them in a secure manner.

## Install gVisor
Go to the gVisor website and copy-paste the installation commands.

```bash
(
  set -e
  ARCH=$(uname -m)
  URL=https://storage.googleapis.com/gvisor/releases/release/latest/${ARCH}
  wget ${URL}/runsc ${URL}/runsc.sha512 \
    ${URL}/containerd-shim-runsc-v1 ${URL}/containerd-shim-runsc-v1.sha512
  sha512sum -c runsc.sha512 \
    -c containerd-shim-runsc-v1.sha512
  rm -f *.sha512
  chmod a+rx runsc containerd-shim-runsc-v1
  sudo mv runsc containerd-shim-runsc-v1 /usr/local/bin
)
```

Remember to do this also in your `worker` node, if you have one!

## Instruct containerd how to use gVisor
As the root user, open the `/etc/containerd/config.toml` file and append the following snippet at the end of the file.

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
```

Now, restart the `containerd` service.

```bash
sudo systemctl restart containerd
```
Remember to do this also in your `worker` node, if you have one!


## Add a `RuntimeClass`
```bash
cat<<EOF | kubectl apply -f -
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor 
handler: runsc
EOF
```

## Run the sandboxed Pod
```bash
cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Pod
metadata:
  name: alpine-sandbox
spec:
  runtimeClassName: gvisor
  containers:
  - image: alpine
    command:
    - sleep
    - "3600"
    name: alpine-sandbox
  restartPolicy: Never
EOF
```

Enter the Pod with
```bash
kubectl exec -it alpine-sandbox -- sh
```

And run:
```
uname -a
# Linux alpine-sandbox 4.4.0 #1 SMP Sun Jan 10 15:06:54 PST 2016 x86_64 Linux
```

Notice the 4.4.0 kernel version. This doesn't clearly indicate we're using gVisor, but if you compare it with our host kernel you'll know that we're not using the same one!
