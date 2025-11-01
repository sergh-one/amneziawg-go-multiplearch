FROM golang:1.24.4 AS builder
COPY . /go/awg
WORKDIR /go/awg
ENV CGO_ENABLED=1
ENV CC=arm-linux-gnueabihf-gcc
ENV GOOS=linux
ENV GOARCH=arm

RUN apt-get update && apt-get install -y gcc-arm-linux-gnueabihf \
    build-essential \
    ca-certificates \
    gcc-arm-linux-gnueabihf \
    binutils-arm-linux-gnueabihf \
    libc6-dev-armhf-cross && \
    git config --global --add safe.directory /go/awg && \
    go mod download && \
    go mod verify && \
    go build -ldflags '-linkmode external -extldflags "-fno-PIC -static"' -v -o /usr/bin && \
    cd amneziawg-tools/src && \
    make

FROM alpine:3.19
# ARG AWGTOOLS_RELEASE="1.0.20250901"

COPY --from=builder /usr/bin/amneziawg-go /usr/bin/amneziawg-go
COPY --from=builder /go/awg/amneziawg-tools/src/wg /usr/bin/awg
COPY --from=builder /go/awg/amneziawg-tools/src/wg-quick/linux.bash /usr/bin/awg-quick

RUN apk --no-cache add iproute2 iptables openresolv bash && \
    chmod +x /usr/bin/awg /usr/bin/awg-quick && \
    ln -s /usr/bin/awg /usr/bin/wg && \
    ln -s /usr/bin/awg-quick /usr/bin/wg-quick