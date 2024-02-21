#!/bin/bash

# Check if SSH server is running
if ! pgrep -x "sshd" > /dev/null; then
    # Start SSH server
    /usr/bin/sshd -D &
    echo "SSH server started."
else
    echo "SSH server is already running."
fi
