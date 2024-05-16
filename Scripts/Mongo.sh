#!/bin/bash

# As we cannot use systemd in the container
# We use this script to start/stop MongoDB

MONGODB_USER="mongod"
MONGODB_LOG="/var/log/mongodb/mongod.log"
MONGODB_PID="/var/lib/mongo/mongod.lock"
MONGODB_KEY="/var/lib/mongo/mongo.key"
MONGODB_CONF="/etc/mongod.conf"

function usage() {
    echo "Usage: $0 {start|stop|status|init}"
    exit 1
}

function start_mongod() {
    if [ -f $MONGODB_PID ] && pgrep -F $MONGODB_PID 2> /dev/null; then
        echo "MongoDB is already running."
    else
        runuser -u $MONGODB_USER -- /usr/bin/mongod --fork --logpath $MONGODB_LOG --config $MONGODB_CONF
        if [ $? -eq 0 ]; then
            echo "MongoDB started successfully."
        else
            echo "Failed to start MongoDB."
            exit 1
        fi
    fi
}

function stop_mongod() {
    if [ -f $MONGODB_PID ] && pgrep -F $MONGODB_PID 2> /dev/null; then
        runuser -u $MONGODB_USER -- kill $(cat $MONGODB_PID)
        if [ $? -eq 0 ]; then
            echo "MongoDB stopped successfully."
        else
            echo "Failed to stop MongoDB."
            exit 1
        fi
    else
        echo "MongoDB is not running."
    fi
}

function status_mongod() {
    if [ -f $MONGODB_PID ] && pgrep -F $MONGODB_PID 2> /dev/null; then
        echo "MongoDB is running."
    else
        echo "MongoDB is not running."
    fi
}

function init_mongod() {
    # Create key file
    openssl rand -base64 756 | tee $MONGODB_KEY
    chown $MONGODB_USER:$MONGODB_USER $MONGODB_KEY
    chmod 400 $MONGODB_KEY

    # Restart MongoDB
    stop_mongod
    sleep 5
    start_mongod || exit 1
    sleep 5

    # Create admin user
    echo 'use admin
    db.createUser({
        user: "admin",
        pwd: "123456",
        roles: [{ role: "root", db: "admin" }]
    })' | mongosh
    echo ""

    # Remove old configuration if exists and update configuration
    sed -i '/authorization:/d' $MONGODB_CONF
    sed -i '/keyFile:/d' $MONGODB_CONF
    sed -i '/replSetName:/d' $MONGODB_CONF

    echo -e "\nsecurity:\n  authorization: enabled\n  keyFile: /var/lib/mongo/mongo.key" >> $MONGODB_CONF
    echo -e "\nreplication:\n  replSetName: crane_rs" >> $MONGODB_CONF
    
    # Restart MongoDB
    stop_mongod
    sleep 5
    start_mongod || exit 1
    sleep 5

    # Initialize replica set
    echo 'use admin
    db.auth("admin","123456")
    rs.initiate({
        _id: "crane_rs",
        members: [{ _id: 0, host: "127.0.0.1:27017" }]
    })' | mongosh
    echo ""

    echo "MongoDB initialized."
}

case "$1" in
    start)
        start_mongod
        ;;
    stop)
        stop_mongod
        ;;
    status)
        status_mongod
        ;;
    init)
        init_mongod
        ;;
    *)
        usage
        ;;
esac
