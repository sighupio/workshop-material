# Vagrant setup
___

### Prerequisites

To follow Vagrant tutorial, you need:
- **VirtualBox** - Follow installation guide on https://www.virtualbox.org/wiki/Downloads to install VirtualBox
- **Vagrant** - Follow installation guide on https://www.vagrantup.com/docs/installation/index.html to install Vagrant

### Step 1 - Start Kubernetes Vagrant cluster

```bash
make vagrant
```

### Step 2 - Delete Kubernetes Vagrant cluster

```bash
make delete
```

Or follow the istruction in the [Makefile](./Makefile)
