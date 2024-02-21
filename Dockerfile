FROM rockylinux:9.3

# Replace mirror for China Mainland
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
    && dnf install -y yum-utils \
    && dnf config-manager --set-enabled crb \
    && dnf clean all

# Install toolchains
RUN dnf update -y \
    && dnf install --allowerasing -y curl \
    && dnf groupinstall -y "Development Tools" \
    && dnf install -y \
    wget \
    unzip \
    git \
    llvm-toolset \
    ccache \
    ninja-build \
    openssh-server \
    && dnf clean all

# cmake && protobuf
RUN wget https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.sh -O /tmp/cmake-install.sh \
    && chmod +x /tmp/cmake-install.sh \
    && /tmp/cmake-install.sh --prefix=/usr/local --skip-license \
    && rm /tmp/cmake-install.sh \
    && wget https://github.com/protocolbuffers/protobuf/releases/download/v23.2/protoc-23.2-linux-x86_64.zip -O /tmp/protoc.zip \
    && unzip /tmp/protoc.zip -d /usr/local \
    && rm /tmp/protoc.zip /usr/local/readme.txt

# Golang
RUN wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -O /tmp/go.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz \
    && echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile.d/go.sh \
    && echo 'export GOPATH=/Workspace/go' >> /etc/profile.d/go.sh \
    && echo 'export PATH=$PATH:$GOPATH/bin' >> /etc/profile.d/go.sh \
    && echo 'go env -w GO111MODULE=on' >> /etc/profile.d/go.sh \
    && echo 'go env -w GOPROXY=https://goproxy.cn,direct' >> /etc/profile.d/go.sh

# Configure Other Envs
RUN ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo 'root:password' | chpasswd

# Add files
WORKDIR /Workspace
COPY ./Scripts /Workspace/Scripts

# Expose SSH port
EXPOSE 22

# Launch SSH at container start
CMD ["/usr/sbin/sshd", "-D"]
