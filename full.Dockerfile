# CraneSched Dev Container

FROM fedora:42
ARG TARGETPLATFORM

LABEL org.opencontainers.image.source=https://github.com/Nativu5/CraneSched-DevContainer
LABEL org.opencontainers.image.description="CraneSched DevContainer"

# Update the system and install basic tools
RUN dnf update -y \
    && dnf install -y --allowerasing curl tar unzip \
    && dnf clean all

# Install protobuf
ARG PROTOC_ZIP
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        PROTOC_ZIP=protoc-23.2-linux-x86_64.zip; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        PROTOC_ZIP=protoc-23.2-linux-aarch_64.zip; \
    fi \
    && curl -L https://github.com/protocolbuffers/protobuf/releases/download/v23.2/${PROTOC_ZIP} -o /tmp/protoc.zip \
    && unzip /tmp/protoc.zip -d /usr/local \
    && rm /tmp/protoc.zip /usr/local/readme.txt

# Install Golang
RUN dnf makecache \
    && dnf install -y golang \
    && dnf clean all \
    && echo 'export PATH=/root/go/bin:$PATH' >> /etc/profile.d/go.sh \
    && echo 'go env -w GO111MODULE=on' >> /etc/profile.d/go.sh \
    && echo 'go env -w GOPROXY=https://goproxy.cn,direct' >> /etc/profile.d/go.sh \
    && source /etc/profile.d/go.sh \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Install toolchains
RUN dnf makecache \
    && dnf install -y \
    gcc \
    gcc-c++ \
    cmake \
    automake \
    git \
    patch \
    flex \
    bison \
    ninja-build \
    && dnf clean all

# Install dependencies
RUN dnf makecache \
    && dnf install -y \
    libstdc++-devel \
    libstdc++-static \
    openssl-devel \
    openssl-devel-engine \
    zlib-devel \
    pam-devel \
    libaio-devel \
    systemd-devel \
    && dnf clean all

# Development Utils
RUN dnf makecache \
    && dnf install -y \
    ccache \
    gdb \
    valgrind \
    vim \
    tmux \
    which \
    ps \
    hostname \
    iproute \
    iputils \
    openssh-server \
    && dnf clean all

# LLVM Toolchain
RUN dnf makecache \
    && dnf install -y \
    clang \
    clang-tools-extra \
    lld \
    lldb \
    && dnf clean all

# Configure extra environment for development
RUN mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo 'root:xFeN1L1Hkbtw' | chpasswd

# Add MongoDB
ARG MONGO_BASE_URL
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        MONGO_BASE_URL=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        MONGO_BASE_URL=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/aarch64/; \
    fi \
    && echo -e "[mongodb-org-8.0]\n\
name=MongoDB Repository\n\
baseurl=${MONGO_BASE_URL}\n\
gpgcheck=1\n\
enabled=1\n\
gpgkey=https://pgp.mongodb.com/server-8.0.asc" > /etc/yum.repos.d/mongodb-org-8.0.repo \
    && dnf install -y mongodb-mongosh-shared-openssl3 mongodb-org \
    && dnf clean all

# Set Workdir
WORKDIR /Workspace

# Expose ports 
# (will not be used till servers launched manually)
EXPOSE 22 27017

CMD ["/bin/bash"]
