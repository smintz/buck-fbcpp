#!/bin/bash
set -e

FB_VERSION="2017.04.10.00"
ZSTD_VERSION="1.1.4"

DEST=$(pwd)/fbcpp/ignore/fbcpp
LINK=$(pwd)/fbcpp/dynamic

MAKE_OPTS="-j 4"

echo "This script configures ubuntu with everything needed to run."
echo "It requires that you run it as root. sudo works great for that."
add-apt-repository -y ppa:ubuntu-toolchain-r/test
source /etc/lsb-release
add-apt-repository -y "deb http://apt.llvm.org/${DISTRIB_CODENAME}/ llvm-toolchain-${DISTRIB_CODENAME}-3.9 main"
wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
apt update

apt install --yes \
    autoconf \
    autoconf-archive \
    automake \
    binutils-dev \
    bison \
    clang-format-3.9 \
    cmake \
    flex \
    g++ \
    git \
    gperf \
    libboost-all-dev \
    libcap-dev \
    libdouble-conversion-dev \
    libevent-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libjemalloc-dev \
    libkrb5-dev \
    liblz4-dev \
    liblzma-dev \
    libnuma-dev \
    libsasl2-dev \
    libsnappy-dev \
    libssl-dev \
    libtool \
    make \
    pkg-config \
    scons \
    wget \
    zip \
    zlib1g-dev

ready_destdir() {
        if [[ -e ${2} ]]; then
                echo "Moving aside existing $1 directory.."
                mv -v "$2" "$2.bak.$(date +%Y-%m-%d)"
        fi
}

mkdir -pv ${DEST}-${FB_VERSION}
rm ${LINK}
ln -sf ${DEST}-${FB_VERSION} ${LINK}

export LDFLAGS="-L${LINK}/lib -Wl,-rpath=${LINK}/lib"
export CPPFLAGS="-I${LINK}/include -std=gnu++14"

cd /tmp

wget -O /tmp/folly-${FB_VERSION}.tar.gz https://github.com/facebook/folly/archive/v${FB_VERSION}.tar.gz
wget -O /tmp/wangle-${FB_VERSION}.tar.gz https://github.com/facebook/wangle/archive/v${FB_VERSION}.tar.gz
wget -O /tmp/fbthrift-${FB_VERSION}.tar.gz https://github.com/facebook/fbthrift/archive/v${FB_VERSION}.tar.gz
wget -O /tmp/proxygen-${FB_VERSION}.tar.gz https://github.com/facebook/proxygen/archive/v${FB_VERSION}.tar.gz
wget -O /tmp/mstch-master.tar.gz https://github.com/no1msd/mstch/archive/master.tar.gz
wget -O /tmp/zstd-${ZSTD_VERSION}.tar.gz https://github.com/facebook/zstd/archive/v${ZSTD_VERSION}.tar.gz

tar xzvf folly-${FB_VERSION}.tar.gz
tar xzvf wangle-${FB_VERSION}.tar.gz
tar xzvf fbthrift-${FB_VERSION}.tar.gz
tar xzvf proxygen-${FB_VERSION}.tar.gz
tar xzvf mstch-master.tar.gz
tar xzvf zstd-${ZSTD_VERSION}.tar.gz

pushd mstch-master
cmake -DCMAKE_INSTALL_PREFIX:PATH=${DEST}-${FB_VERSION} .
make ${MAKE_OPTS} install
popd

pushd zstd-${ZSTD_VERSION}
make ${MAKE_OPTS} install PREFIX=${DEST}-${FB_VERSION}
popd


pushd folly-${FB_VERSION}/folly
autoreconf -ivf
./configure --prefix=${DEST}-${FB_VERSION}
make ${MAKE_OPTS} install
popd

pushd wangle-${FB_VERSION}/wangle
sed "s/add_library(wangle.*/add_library(wangle STATIC" CMakeLists.txt -i.orig
cmake -DCMAKE_INSTALL_PREFIX:PATH=${DEST}-${FB_VERSION} -DBUILD_SHARED_LIBS:BOOL=ON .
make ${MAKE_OPTS}
# Wangle tests are broken. Disabling ctest.
# ctest
make install
popd

pushd fbthrift-${FB_VERSION}/thrift
autoreconf -ivf
./configure --with-folly=${DEST} --prefix=${DEST}-${FB_VERSION}
make ${MAKE_OPTS} install
popd

pushd proxygen-${FB_VERSION}/proxygen
autoreconf -ivf
./configure LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" --prefix=${DEST}-${FB_VERSION}
make ${MAKE_OPTS} install
popd
