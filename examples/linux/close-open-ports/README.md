# Close Open Ports

In this exercise we learn how to find unwanted processes and how to clean them.

1. Make the exercise run

```bash
sudo su
chmod +x setup.sh
./setup.sh
```

2. Inspect the network

```bash
apt install net-tools

netstat -tulpn | grep 1234
```

You will see a result similar to the following:

```
tcp        0      0 0.0.0.0:1234            0.0.0.0:*               LISTEN      11942/app1
```

The number `11942` in the example is the PID of the process.

3. Find the full path

```bash
# Take the number you got above and put it in place of $PID
ls -l /proc/$PID/exe
```

You will see something like this:

```bash
lrwxrwxrwx 1 root root 0 Oct 14 15:28 /proc/11942/exe -> /usr/bin/app1
```

This means that application `app1` is the culprit!


4. Kill the process and delete the binary

```bash
kill $PID
rm /usr/bin/app1
```
