# CraneSched Dev Container
# Tag: cranedev:gcc11-llvm

FROM rockylinux:9.3

# Replace mirror for China Mainland and add EPEL
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/rocky-extras.repo \
    /etc/yum.repos.d/rocky.repo \
    && dnf update -y \
    && dnf install -y epel-release \
    && sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirrors.tuna.tsinghua.edu.cn/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirrors.tuna.tsinghua.edu.cn/epel!g' \
    -i /etc/yum.repos.d/epel{,-testing}.repo \
    && dnf install -y --allowerasing yum-utils curl unzip \
    && dnf config-manager --set-enabled crb \
    && dnf clean all

# Install cmake and protobuf
RUN curl -L https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.sh -o /tmp/cmake-install.sh \
    && chmod +x /tmp/cmake-install.sh \
    && /tmp/cmake-install.sh --prefix=/usr/local --skip-license \
    && rm /tmp/cmake-install.sh \
    && curl -L https://github.com/protocolbuffers/protobuf/releases/download/v23.2/protoc-23.2-linux-x86_64.zip -o /tmp/protoc.zip \
    && unzip /tmp/protoc.zip -d /usr/local \
    && rm /tmp/protoc.zip /usr/local/readme.txt

# Golang
RUN curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -o /tmp/go.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz \
    && echo 'export GOPATH=/Workspace/go' >> /etc/profile.d/go.sh \
    && echo 'export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH' >> /etc/profile.d/go.sh \
    && echo 'go env -w GO111MODULE=on' >> /etc/profile.d/go.sh \
    && echo 'go env -w GOPROXY=https://goproxy.cn,direct' >> /etc/profile.d/go.sh

# Install toolchains
RUN dnf makecache \
    && dnf install -y \
    gcc \
    g++ \
    libstdc++-devel \
    libstdc++-static \
    llvm-toolset \
    git \
    which \
    patch \
    flex \
    bison \
    ninja-build \
    && dnf clean all

# Install dependencies
RUN dnf makecache \ 
    && dnf install -y \
    openssl-devel \
    zlib-devel \
    pam-devel \
    libaio-devel \
    systemd-devel \
    && dnf clean all \
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
    ccache \
    lldb \
    gdb \
    valgrind \
    vim \
    tmux \
    iproute \
    openssh-server \
    && dnf clean all

# Configure extra environment
RUN mkdir /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo 'root:xFeN1L1Hkbtw' | chpasswd

# Add files
WORKDIR /Workspace
COPY ./Scripts /Workspace/Scripts

# Expose SSH port
EXPOSE 22

# Launch SSH at container start
CMD ["/usr/sbin/sshd", "-D"]