#!/bin/bash

# This script is used to display a banner when log in. 
source /etc/os-release
echo "=================================================="
echo "Welcome to the CraneSched's Dev Container"
echo "System: $PRETTY_NAME"
echo "Toolchain: gcc, llvm, cmake, golang, protobuf"
echo "Check \`/Workspace/Scripts\` for more information."
echo "=================================================="
