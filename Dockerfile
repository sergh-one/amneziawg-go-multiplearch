FROM golang:1.24.4 AS awg
COPY . /awg
WORKDIR /awg
ENV CGO_ENABLED=1
ENV CC=arm-linux-gnueabihf-gcc
ENV GOOS=linux
ENV GOARCH=arm

RUN apt-get update && apt-get install -y gcc-arm-linux-gnueabihf && \
    go mod download && \
    go mod verify && \
    go build -ldflags '-linkmode external -extldflags "-fno-PIC -static"' -v -o /usr/bin

FROM alpine:3.19
ARG AWGTOOLS_RELEASE="1.0.20250901"

RUN apk --no-cache add iproute2 iptables openresolv bash && \
    cd /usr/bin/ && \
    wget https://github.com/amnezia-vpn/amneziawg-tools/releases/download/v${AWGTOOLS_RELEASE}/alpine-3.19-amneziawg-tools.zip && \
    unzip -j alpine-3.19-amneziawg-tools.zip && \
    chmod +x /usr/bin/awg /usr/bin/awg-quick && \
    ln -s /usr/bin/awg /usr/bin/wg && \
    ln -s /usr/bin/awg-quick /usr/bin/wg-quick
COPY --from=awg /usr/bin/amneziawg-go /usr/bin/amneziawg-go
