# Restrict kernel modules

In this exercise we'll learn how to prevent some kernel modules to be loaded at boot. We'll blacklist the wireguard module. (You shouldn't be using this in your workshop, but ask your instructor first, please)

1. List all loaded kernel modules

```bash
sudo su
lsmod
```

2. Inspect the list and look for wireguard

```bash
lsmod | grep wireguard
```

You will see a result similar to the following:

```
wireguard             118784  0
```

3. Add the module to the blocklist

```bash
sudo vim /etc/modprobe.d/wireguard.conf
```

4. Add the blacklist entry
```plaintext
blacklist wireguard
```

5. Reboot
```bash
sudo shutdown -r now
```

6. Login again and check if wireguard is loaded
```bash
sudo lsmod | grep wireguard
# It should return no results!
```
