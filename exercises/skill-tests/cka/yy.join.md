# Question - join

Eseguite il join del nodo uninitialised-worker-1 . Utilizzate la stessa versione attualmente installata nel cluster.

## Solution

Per prima cosa create il join token dal nodo master:

```bash
kubeadm token create --print-join-command
```

Vi verrà dato un comando in questa forma:

`kubeadm join 172.31.5.213:6443 --token s4vl1y.qqhevqerivm4wp6t     --discovery-token-ca-cert-hash sha256:be6ec6459e2255fd799b28a3b23a3552c7b2ea483867552882af3de819d8ee16`

Aggiungiamo il flag `--node-name=$(hostname -f)` per avere l'hostname corretto nella registrazione del nodo.

Collegatevi ad un nodo non inizializzato ed eseguite il join.



