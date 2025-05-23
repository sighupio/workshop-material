# Quick-start with Falco
This simple exercise provides a simple way to deploy Falco on your Kubernetes cluster and provision a custom rule.

## Install Falco with Helm
Install the Helm Falco repository

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Actually install Falco
```bash
helm install --replace falco --namespace falco --create-namespace --set tty=true falcosecurity/falco
```

## Wait for Falco Pods to come up
```bash
kubectl wait pods --for=condition=Ready --all -n falco
```

## Trigger a default rule
```bash
kubectl run nginx-offending --image=nginx
```

And access a sensitive file.
```bash
kubectl exec -it nginx-offending -- cat /etc/shadow
```

## Look at Falco's logs: there's something!
```plaintext
kubectl logs -l app.kubernetes.io/name=falco -n falco -c falco | grep Warning
09:46:05.727801343: Warning Sensitive file opened for reading by non-trusted program (file=/etc/shadow gparent=systemd ggparent=<NA> gggparent=<NA> evt_type=openat user=root user_uid=0 user_loginuid=-1 process=cat proc_exepath=/usr/bin/cat parent=containerd-shim command=cat /etc/shadow terminal=34816 container_id=bf74f1749e23 container_image=docker.io/library/nginx container_image_tag=latest container_name=nginx k8s_ns=default k8s_pod_name=nginx-7854ff8877-h97p4)
```

## Create a custom rule!
We want to be alerted whenever someone opens for writing a file under `/etc`. Why? Because!

Create a file and call it `falco_custom_rules_cm.yaml` with the following content:
```yaml
customRules:
  custom-rules.yaml: |-
    - rule: Write below etc
      desc: An attempt to write to /etc directory
      condition: >
        (evt.type in (open,openat,openat2) and evt.is_open_write=true and fd.typechar='f' and fd.num>=0)
        and fd.name startswith /etc
      output: "File below /etc opened for writing (file=%fd.name pcmdline=%proc.pcmdline gparent=%proc.aname[2] ggparent=%proc.aname[3] gggparent=%proc.aname[4] evt_type=%evt.type user=%user.name user_uid=%user.uid user_loginuid=%user.loginuid process=%proc.name proc_exepath=%proc.exepath parent=%proc.pname command=%proc.cmdline terminal=%proc.tty %container.info)"
      priority: WARNING
      tags: [filesystem, mitre_persistence]
```

## Load it!
```bash
helm upgrade --namespace falco falco falcosecurity/falco --set tty=true -f falco_custom_rules_cm.yaml
```

And wait
```bash
kubectl wait pods --for=condition=Ready --all -n falco
```

## Trigger the rule
```bash
kubectl exec -it nginx-offending -- touch /etc/test_file_for_falco_rule
```

## Look at the logs
```bash
kubectl logs -l app.kubernetes.io/name=falco -n falco -c falco | grep Warning
```

You should find the violation of our custom rule caused by our file!
