# CraneSched Dev Container

FROM rockylinux/rockylinux:9.4

LABEL org.opencontainers.image.source https://github.com/Nativu5/CraneSched-DevContainer
LABEL org.opencontainers.image.description "CraneSched DevContainer"

# Add EPEL and CRB repositories
RUN dnf update -y \
    && dnf install -y epel-release \
    && dnf install -y --allowerasing yum-utils curl unzip \
    && dnf config-manager --set-enabled crb \
    && dnf clean all

# Install protobuf
RUN curl -L https://github.com/protocolbuffers/protobuf/releases/download/v23.2/protoc-23.2-linux-x86_64.zip -o /tmp/protoc.zip \
    && unzip /tmp/protoc.zip -d /usr/local \
    && rm /tmp/protoc.zip /usr/local/readme.txt

# Golang
RUN curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -o /tmp/go.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz \
    && echo 'export GOPATH=/root/go' >> /etc/profile.d/go.sh \
    && echo 'export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH' >> /etc/profile.d/go.sh \
    && echo 'go env -w GO111MODULE=on' >> /etc/profile.d/go.sh \
    && echo 'go env -w GOPROXY=https://goproxy.cn,direct' >> /etc/profile.d/go.sh \ 
    && source /etc/profile.d/go.sh \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Install toolchains
RUN dnf makecache \
    && dnf install -y \
    gcc-toolset-13 \
    cmake \
    git \
    patch \
    flex \
    bison \
    ninja-build \
    && dnf clean all \
    && echo 'source /opt/rh/gcc-toolset-13/enable' >> /etc/profile.d/extra.sh 

# Install dependencies
RUN dnf makecache \ 
    && dnf install -y \
    openssl-devel \
    zlib-devel \
    pam-devel \
    libaio-devel \
    systemd-devel \
    && dnf clean all \
    && source /opt/rh/gcc-toolset-13/enable \
    && curl -L https://github.com/libcgroup/libcgroup/releases/download/v3.1.0/libcgroup-3.1.0.tar.gz -o /tmp/libcgroup.tar.gz \
    && tar -C /tmp -xzf /tmp/libcgroup.tar.gz \
    && cd /tmp/libcgroup-3.1.0 \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/libcgroup-3.1.0 /tmp/libcgroup.tar.gz \
    && echo 'export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH' >> /etc/profile.d/extra.sh

# Development Utils
RUN dnf makecache \
    && dnf install -y \
    llvm-toolset \
    libstdc++-static \
    ccache \
    lldb \
    gdb \
    valgrind \
    vim \
    tmux \
    which \
    iproute \
    iputils \
    openssh-server \
    && dnf clean all

# Configure extra environment for development
RUN mkdir /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo 'root:xFeN1L1Hkbtw' | chpasswd \
    && echo 'export PATH=/usr/lib64/ccache:$PATH' >> /etc/profile.d/extra.sh

# Set Workdir
WORKDIR /Workspace

# Expose SSH port 
# (will not be used till sshd launched manually)
EXPOSE 22

CMD ["/bin/bash"]
