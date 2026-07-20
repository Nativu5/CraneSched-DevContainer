# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=docker.io/library/fedora@sha256:52cfb35e60823b691af7541b576c0fa49195628044b2c1a15b0ae775ec01048e
FROM ${BASE_IMAGE}

ARG TARGETARCH=amd64

LABEL org.opencontainers.image.source="https://github.com/Nativu5/CraneSched-DevContainer" \
      org.opencontainers.image.description="CraneSched build-only toolchain" \
      io.cranesched.image.variant="toolchain"

RUN dnf install -y --setopt=install_weak_deps=False \
        automake \
        bison \
        ca-certificates \
        ccache \
        clang \
        cmake \
        curl \
        elfutils-libelf-devel \
        flex \
        gawk \
        gcc \
        gcc-c++ \
        libstdc++-devel \
        libstdc++-static \
        git \
        libaio-devel \
        libbpf-devel \
        libcurl-devel \
        lld \
        libtool \
        llvm \
        lua-devel \
        make \
        ninja-build \
        openssl-devel \
        openssl-devel-engine \
        pam-devel \
        patch \
        pkgconf-pkg-config \
        shadow-utils-subid-devel \
        systemd-devel \
        tar \
        unzip \
        which \
        zlib-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf

ARG GO_VERSION=1.25.4
ARG GO_AMD64_SHA256=9fa5ffeda4170de60f67f3aa0f824e426421ba724c21e133c1e35d6159ca1bec
ARG GO_ARM64_SHA256=a68e86d4b72c2c2fecf7dfed667680b6c2a071221bbdb6913cf83ce3f80d9ff0
RUN case "${TARGETARCH}" in \
        amd64) go_arch=amd64; go_sha256="${GO_AMD64_SHA256}" ;; \
        arm64) go_arch=arm64; go_sha256="${GO_ARM64_SHA256}" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${go_arch}.tar.gz" \
    && printf '%s  %s\n' "${go_sha256}" /tmp/go.tar.gz | sha256sum -c - \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm -f /tmp/go.tar.gz

ARG PROTOC_VERSION=23.2
ARG PROTOC_AMD64_SHA256=179a759581bf4b32cc5edae4ffce6b8ee16ba4f4ab99ad3a309c31113f98d472
ARG PROTOC_ARM64_SHA256=12c9385da533dd5fe6fd57e0c5cdb7004d8c08af94a80c75614c50f1f31d92e0
RUN case "${TARGETARCH}" in \
        amd64) protoc_arch=x86_64; protoc_sha256="${PROTOC_AMD64_SHA256}" ;; \
        arm64) protoc_arch=aarch_64; protoc_sha256="${PROTOC_ARM64_SHA256}" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSLo /tmp/protoc.zip \
        "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-${protoc_arch}.zip" \
    && printf '%s  %s\n' "${protoc_sha256}" /tmp/protoc.zip | sha256sum -c - \
    && unzip -q /tmp/protoc.zip -d /usr/local \
    && rm -f /tmp/protoc.zip /usr/local/readme.txt

ENV PATH=/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin \
    GOPATH=/go \
    GOTOOLCHAIN=local \
    GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct \
    OPENSSL_ROOT_DIR=/usr \
    OPENSSL_INCLUDE_DIR=/usr/include \
    OPENSSL_SSL_LIBRARY=/usr/lib64/libssl.so \
    OPENSSL_CRYPTO_LIBRARY=/usr/lib64/libcrypto.so

ARG PROTOC_GEN_GO_VERSION=1.36.5
ARG PROTOC_GEN_GO_GRPC_VERSION=1.5.1
RUN GOBIN=/usr/local/bin go install \
        "google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOC_GEN_GO_VERSION}" \
    && GOBIN=/usr/local/bin go install \
        "google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VERSION}" \
    && rm -rf /go/pkg/mod /root/.cache/go-build

COPY --chmod=0755 Scripts/toolchain-smoke.sh /usr/local/bin/toolchain-smoke
RUN /usr/local/bin/toolchain-smoke

WORKDIR /
CMD ["/usr/bin/true"]
