#!/bin/bash

# Script name: manage_sshd.sh
# Purpose: Manage the start, stop, and status of sshd in a container

SSHD_PID_FILE="/run/sshd.pid"

start_sshd() {
    if [ -f $SSHD_PID_FILE ]; then
        echo "sshd is already running."
    else
        echo "Starting sshd..."
        /usr/sbin/sshd
        if [ $? -eq 0 ]; then
            echo "sshd started successfully."
        else
            echo "Failed to start sshd."
        fi
    fi
}

stop_sshd() {
    if [ -f $SSHD_PID_FILE ]; then
        echo "Stopping sshd..."
        kill $(cat $SSHD_PID_FILE)
        if [ $? -eq 0 ]; then
            echo "sshd stopped successfully."
            rm -f $SSHD_PID_FILE
        else
            echo "Failed to stop sshd."
        fi
    else
        echo "sshd is not running."
    fi
}

status_sshd() {
    if [ -f $SSHD_PID_FILE ]; then
        PID=$(cat $SSHD_PID_FILE)
        if ps -p $PID > /dev/null; then
            echo "sshd is running (PID: $PID)."
        else
            echo "sshd is not running, but PID file exists."
        fi
    else
        if pgrep -x "sshd" > /dev/null; then
            echo "sshd is running."
        else
            echo "sshd is not running."
        fi
    fi
}

case "$1" in
    start)
        start_sshd
        ;;
    stop)
        stop_sshd
        ;;
    status)
        status_sshd
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
esac

exit 0
