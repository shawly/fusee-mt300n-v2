FROM ubuntu:16.04

RUN apt-get update && apt-get install build-essential subversion mercurial libncurses5-dev zlib1g-dev gawk gcc-multilib flex git-core gettext libssl-dev unzip wget python file sudo -y && mkdir -p /build && useradd -ms /bin/bash build && chown build:build /build

USER build

WORKDIR /build

RUN git clone https://github.com/DavidBuchanan314/fusee-lede.git && \
    git clone -b lede-17.01 https://git.openwrt.org/source.git lede && \
    git clone https://github.com/gl-inet/imagebuilder-lede-ramips imagebuilder && \
    git clone https://github.com/gl-inet/openwrt-files.git imagebuilder/files && \
    cp -r fusee-lede/fusee-nano lede/package/utils/

COPY .config /build/lede

WORKDIR /build/lede

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

RUN make tools/install V=s && make toolchain/install V=s

RUN make package/fusee-nano/compile && \
    make package/fusee-nano/install && \
    cp bin/packages/mipsel_24kc/base/fusee-nano*.ipk ../imagebuilder/packages

WORKDIR /build/imagebuilder

VOLUME /build/imagebuilder/bin

ENTRYPOINT make

CMD image PROFILE=gl-mt300n-v2 PACKAGES="kmod-mt7628 uci2dat mtk-iwinfo luci fusee-nano" FILES=files/files-clean-mt7628/