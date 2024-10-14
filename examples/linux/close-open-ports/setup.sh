#!/bin/bash
apt install netcat > /dev/null
cp /usr/bin/nc /usr/bin/app1
/usr/bin/app1 -l 1234 &
