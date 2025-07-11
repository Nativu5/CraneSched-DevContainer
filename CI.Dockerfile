# CraneSched Dev Container

# This image is used for CI/CD pipeline, so we need a rather older base image to ensure compatibility.
FROM rockylinux/rockylinux:8
ARG TARGETPLATFORM

LABEL org.opencontainers.image.source=https://github.com/Nativu5/CraneSched-DevContainer
LABEL org.opencontainers.image.description="CraneSched DevContainer (CI)"

# Add EPEL and PowerTools repositories
RUN dnf update -y \
    && dnf install -y epel-release \
    && dnf install -y --allowerasing yum-utils curl tar unzip \
    && dnf config-manager --set-enabled powertools \
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
    && rm -f /tmp/protoc.zip /usr/local/readme.txt

ARG GOLANG_TARBALL
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        GOLANG_TARBALL=go1.23.0.linux-amd64.tar.gz; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        GOLANG_TARBALL=go1.23.0.linux-arm64.tar.gz; \
    fi \
    && curl -L https://go.dev/dl/${GOLANG_TARBALL} -o /tmp/go.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm -f /tmp/go.tar.gz \
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
    gcc-toolset-14 \
    cmake \
    ccache \
    automake \
    git \
    gawk \
    patch \
    flex \
    bison \
    ninja-build \
    rpm-build \
    dpkg \
    && dnf clean all \
    && echo 'source /opt/rh/gcc-toolset-14/enable' >> /etc/profile.d/extra.sh 

# Install dependencies
RUN dnf makecache \
    && dnf install -y \
    openssl3-devel \
    zlib-devel \
    pam-devel \
    libaio-devel \
    libcurl-devel \
    systemd-devel \
    && dnf clean all

# Rocky Linux 8 use OpenSSL 1.1 by default, but we prefer OpenSSL 3.
# To simplify the building command, we create symbolic links to OpenSSL 3. 
# However, this is a BAD practice in production environment.
# In production, you should use `CMake -DOPENSSL_...` to use OpenSSL 3.
RUN ln -s /usr/lib64/libssl.so.3 /usr/lib64/libssl.so \
    && ln -s /usr/lib64/libcrypto.so.3 /usr/lib64/libcrypto.so \
    && ln -s /usr/lib64/pkgconfig/openssl3.pc /usr/lib64/pkgconfig/openssl.pc \
    && echo 'export OPENSSL_ROOT_DIR=/usr/include/openssl3' >> /etc/profile.d/extra.sh \
    && echo 'export OPENSSL_INCLUDE_DIR=/usr/include/openssl3' >> /etc/profile.d/extra.sh \
    && echo 'export OPENSSL_SSL_LIBRARY=/usr/lib64/openssl3/libssl.so' >> /etc/profile.d/extra.sh \
    && echo 'export OPENSSL_CRYPTO_LIBRARY=/usr/lib64/openssl3/libcrypto.so' >> /etc/profile.d/extra.sh

WORKDIR /Workspace
CMD [ "/bin/bash" ]
