#!/bin/bash



COMMAND="ssh -o TCPKeepAlive=no -o ServerAliveInterval=15 -oExitOnForwardFailure=yes -N -f -R 87.118.68.207:10000:127.0.0.1:22 -p81 root@xen10001.newshell.it"
pgrep -f -x "$COMMAND" > /dev/null 2>&1 || $COMMAND

