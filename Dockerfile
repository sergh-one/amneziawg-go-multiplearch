FROM golang:1.24.4 AS awg
COPY . /awg
WORKDIR /awg
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
    go mod download && \
    go mod verify && \
    go build -ldflags '-linkmode external -extldflags "-fno-PIC -static"' -v -o /usr/bin && \
    cd amnezia-tools/src && \
    make

FROM alpine:3.19
# ARG AWGTOOLS_RELEASE="1.0.20250901"

COPY --from=awg /usr/bin/amneziawg-go /usr/bin/amneziawg-go
COPY --from=awg /go/awg/amneziawg-tools/src/wg /usr/bin/awg
COPY --from=awg /go/awg/amneziawg-tools/src/wg-quick/${GOOS}.bash /usr/bin/awg-quick

RUN apk --no-cache add iproute2 iptables openresolv bash && \
    chmod +x /usr/bin/awg /usr/bin/awg-quick && \
    ln -s /usr/bin/awg /usr/bin/wg && \
    ln -s /usr/bin/awg-quick /usr/bin/wg-quick