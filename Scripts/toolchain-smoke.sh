#!/bin/sh

set -eu

for command in \
  ccache clang cmake curl g++ gcc git go make ninja pkg-config protoc \
  protoc-gen-go protoc-gen-go-grpc; do
  command -v "${command}" >/dev/null
done

case "$(gcc -dumpfullversion)" in
  15.*) ;;
  *) echo "expected GCC 15, found $(gcc -dumpfullversion)" >&2; exit 1 ;;
esac

test "$(go env GOVERSION)" = "go1.25.4"
test "$(protoc --version)" = "libprotoc 23.2"
test "$(protoc-gen-go --version)" = "protoc-gen-go v1.36.5"
test "$(protoc-gen-go-grpc --version)" = "protoc-gen-go-grpc 1.5.1"

for excluded in gdb lldb mongod sshd; do
  if command -v "${excluded}" >/dev/null 2>&1; then
    echo "build-only toolchain unexpectedly contains ${excluded}" >&2
    exit 1
  fi
done
test ! -e /Workspace

if test -L /usr/lib64/libssl.so && test "$(readlink /usr/lib64/libssl.so)" = "/usr/lib64/libssl.so.3"; then
  echo "global OpenSSL replacement symlink is forbidden" >&2
  exit 1
fi
if test -L /usr/lib64/libcrypto.so && test "$(readlink /usr/lib64/libcrypto.so)" = "/usr/lib64/libcrypto.so.3"; then
  echo "global OpenSSL replacement symlink is forbidden" >&2
  exit 1
fi
if test -L /usr/lib64/pkgconfig/openssl.pc && test "$(readlink /usr/lib64/pkgconfig/openssl.pc)" = "/usr/lib64/pkgconfig/openssl3.pc"; then
  echo "global OpenSSL pkg-config replacement symlink is forbidden" >&2
  exit 1
fi

temporary="$(mktemp -d)"
trap 'rm -rf "${temporary}"' EXIT HUP INT TERM

cat >"${temporary}/hello.cc" <<'EOF'
#include <iostream>
int main() { std::cout << "toolchain"; }
EOF
g++ -std=c++20 -Wall -Werror "${temporary}/hello.cc" -o "${temporary}/hello"
test "$("${temporary}/hello")" = "toolchain"

cat >"${temporary}/openssl.c" <<'EOF'
#include <openssl/engine.h>
#include <openssl/ssl.h>
int main(void) { return OPENSSL_VERSION_NUMBER == 0; }
EOF
gcc -Wall -Werror \
  -I"${OPENSSL_INCLUDE_DIR}" \
  "${temporary}/openssl.c" \
  "${OPENSSL_SSL_LIBRARY}" \
  "${OPENSSL_CRYPTO_LIBRARY}" \
  -o "${temporary}/openssl"
"${temporary}/openssl"

cat >"${temporary}/libbpf.c" <<'EOF'
#include <bpf/libbpf.h>
int main(void) { return libbpf_set_strict_mode(LIBBPF_STRICT_ALL); }
EOF
gcc -Wall -Werror "${temporary}/libbpf.c" -lbpf -lelf -lz -o "${temporary}/libbpf"
"${temporary}/libbpf"

cat >"${temporary}/hello.go" <<'EOF'
package main
func main() {}
EOF
go build -trimpath -o "${temporary}/hello-go" "${temporary}/hello.go"
test -x "${temporary}/hello-go"

printf '%s\n' '{"event":"toolchain-smoke-passed"}'
