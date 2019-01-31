#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $BASH_SOURCE)

# Absolute path this script is in. /home/user/bin
SCRIPTPATH=$(dirname $SCRIPT)

set -e

LIBUSB_VER=1.0.22
ZLIB_VER=1.2.11

PREFIX=${SCRIPTPATH}/mingw64

do_install_libusb()
{
  wget https://github.com/libusb/libusb/releases/download/v${LIBUSB_VER}/libusb-${LIBUSB_VER}.tar.bz2
  tar jxf libusb-${LIBUSB_VER}.tar.bz2
  pushd libusb-${LIBUSB_VER}
  ./configure --prefix=${PREFIX} --host=x86_64-w64-mingw32
  make
  make install
  popd
}

do_install_zlib()
{
  wget http://zlib.net/zlib-${ZLIB_VER}.tar.gz
  tar zxf zlib-${ZLIB_VER}.tar.gz
  pushd zlib-${ZLIB_VER}
  CC=x86_64-w64-mingw32-gcc ./configure --prefix=${PREFIX} --static --64
  CC=x86_64-w64-mingw32-gcc make
  CC=x86_64-w64-mingw32-gcc make install
  popd
}

do_install_zlib
do_install_libusb
git clone https://github.com/linux-sunxi/sunxi-tools.git
pushd sunxi-tools
make CC=x86_64-w64-mingw32-gcc  OS="Windows_NT" LIBUSB_CFLAGS="-static -I${PREFIX}/include/libusb-1.0 -I${PREFIX}/include" LIBUSB_LIBS="-L${PREFIX}/lib -lusb-1.0 -lz -pthread" clean sunxi-fel
cp sunxi-fel sunxi-fel.exe
popd

printf "sunxi-fel.exe is available here: %s\n"  ${SCRIPTPATH}/sunxi-tools/sunxi-fel.exe
