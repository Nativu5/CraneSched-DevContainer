#!/bin/bash

usage() {
    echo "Usage: $0 --mode <frontend|backend>"
    exit 1
}

frontend() {
    echo "Building frontend..."

    pushd /Workspace
    mkdir out 
    mkdir -p generated/protos
    protoc --go_out=./generated --go-grpc_out=./generated --proto_path=./protos ./protos/*.proto

    pushd out
    go build ../cmd/cacct/cacct.go
    go build ../cmd/cacctmgr/cacctmgr.go
    go build ../cmd/cbatch/cbatch.go 
    go build ../cmd/ccancel/ccancel.go 
    go build ../cmd/ccontrol/ccontrol.go 
    go build ../cmd/cinfo/cinfo.go
    go build ../cmd/cqueue/cqueue.go
    
    echo "Done."
}

backend() {
    echo "Building backend..."

    pushd /Workspace
    mkdir out
    mkdir cmake-build-release && pushd cmake-build-release
    cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_UNQLITE=ON \
    -DENABLE_BERKELEY_DB=OFF \
    -DCRANE_FULL_DYNAMIC=OFF \
    -DCRANE_USE_GITEE_SOURCE=OFF .. 
    cmake --build .
    mv src/Craned/craned ../out/
    mv src/CraneCtld/cranectld ../out/
    mv src/Misc/Pam/pam_crane.so ../out/
    
    echo "Done."
}

# Check flags
if [ "$#" -ne 2 ]; then
    usage
fi

while [ "$1" != "" ]; do
    case $1 in
        --mode )
            shift
            mode=$1
            ;;
        * )
            usage
            ;;
    esac
    shift
done

# Run setup based on mode
case $mode in
    frontend )
        frontend
        ;;
    backend )
        backend
        ;;
    * )
        echo "Error: Invalid mode value. Use 'frontend' or 'backend'."
        exit 1
        ;;
esac
