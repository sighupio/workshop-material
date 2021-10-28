echo "[TASK 1] Join node to Kubernetes Cluster"
apt install -qq -y sshpass >/dev/null 2>&1
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no controlplane:/joincluster.sh /joincluster.sh
bash /joincluster.sh >/dev/null 2>&1