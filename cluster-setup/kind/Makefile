kind:
	kind create cluster --config kind-config.yml --name kind

kubeconfig:
	kind get kubeconfig --name kind > kubeconfig

delete:
	kind delete cluster --name kind
