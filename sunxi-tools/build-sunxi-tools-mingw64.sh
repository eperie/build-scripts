# Copyright (c) 2017-2022, Éric Périé
# 
#  SPDX-License-Identifier: BSD-3-Clause
# 
# Script for building a mingw64 version of sunxi-tools on Ubuntu 16.04.
#

#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $BASH_SOURCE)

# Absolute path this script is in. /home/user/bin
SCRIPTPATH=$(dirname $SCRIPT)

# terminate on error
set -e

PACKAGES_DIR=${SCRIPTPATH}/packages
BUILD_DIR=${SCRIPTPATH}/build
SYSROOT_DIR=${SCRIPTPATH}/sysroot

LIBUSB_VERSION=1.0.26
LIBUSB_ARCHIVE=libusb-${LIBUSB_VERSION}.tar.bz2
LIBUSB_URL=https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/${LIBUSB_ARCHIVE}
LIBUSB_HOME=${SCRIPTPATH}/sysroot

ZLIB_VERSION=1.2.13
ZLIB_ARCHIVE=zlib-${ZLIB_VERSION}.tar.gz
ZLIB_URL=http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz

do_clean()
{
  rm -rf ${BUILD_DIR} ${SYSROOT_DIR}
}

do_distclean()
{
  rm -rf ${BUILD_DIR} ${SYSROOT_DIR}
}

do_get_zlib()
{
  if [ ! -f ${PACKAGES_DIR}/zlib-${ZLIB_VERSION}.tar.gz ]
  then
    mkdir -p ${PACKAGES_DIR}
    wget ${ZLIB_URL} -O ${PACKAGES_DIR}/zlib-${ZLIB_VERSION}.tar.gz
  fi
}

do_extract_zlib()
{
  tar zxf ${PACKAGES_DIR}/${ZLIB_ARCHIVE} -C ${BUILD_DIR}
}

do_build_zlib()
{
  pushd  ${BUILD_DIR}/zlib-${ZLIB_VERSION}
  CC=x86_64-w64-mingw32-gcc ./configure --static  --prefix=${SYSROOT_DIR}
  make all install
  popd
}

do_get_libusb()
{
  if [ ! -f ${PACKAGES_DIR}/libusb-${LIBUSB_VERSION}.tar.bz2 ]
  then
    mkdir -p ${PACKAGES_DIR}
    wget ${LIBUSB_URL} -O ${PACKAGES_DIR}/libusb-${LIBUSB_VERSION}.tar.bz2
  fi
}

do_extract_libusb()
{
  rm -rf  ${BUILD_DIR}/libusb-${LIBUSB_VERSION}
  tar jxf ${PACKAGES_DIR}/${LIBUSB_ARCHIVE} -C ${BUILD_DIR}
}
  
do_build_libusb()
{
  mkdir -p ${SYSROOT_DIR}
  pushd ${BUILD_DIR}/libusb-${LIBUSB_VERSION}
  ./configure --prefix=${SYSROOT_DIR} --host=x86_64-w64-mingw32
  make
  make install
  popd
}

do_get_sunxi_tools()
{
  rm -rf ${BUILD_DIR}/sunxi-tools
  git -C ${BUILD_DIR} clone https://github.com/linux-sunxi/sunxi-tools.git
}

do_build_sunxi_tools()
{
  make -C ${BUILD_DIR}/sunxi-tools PREFIX=${BUILD_DIR}/sunxi-tools-mingw64 CC=x86_64-w64-mingw32-gcc ZLIB_CFLAGS="-static -I${SYSROOT_DIR}/include" ZLIB_LIBS="-L${SYSROOT_DIR}/lib -lz"  OS="Windows_NT" LIBUSB_CFLAGS="-I${SYSROOT_DIR}/include/libusb-1.0" LIBUSB_LIBS="-L${SYSROOT_DIR}/lib -lusb-1.0 -pthread"
}

do_package_sunxi_tools()
{
  mkdir -p ${BUILD_DIR}/sunxi-tools-mingw64-${REVISION}
  pushd  ${BUILD_DIR}/sunxi-tools
  REVISION=$(git log -n1 --pretty='%h')
  for FILE in *.exe 
  do
    x86_64-w64-mingw32-strip ${FILE}
    cp ${BUILD_DIR}/sunxi-tools/${FILE} ${BUILD_DIR}/sunxi-tools-mingw64-${REVISION}
  done

  pushd ${BUILD_DIR}
  zip -r ${SCRIPTPATH}/sunxi-tools-mingw64-${REVISION}.zip sunxi-tools-mingw64-${REVISION}
  popd

  popd
}

# debug
# exit 0

# main

# cleanup
#do_distclean

mkdir -p ${BUILD_DIR} 

# zlib
do_get_zlib
do_extract_zlib
do_build_zlib

# libusb
do_get_libusb
do_extract_libusb
do_build_libusb

# sunxi-tools
do_get_sunxi_tools
do_build_sunxi_tools
do_package_sunxi_tools

printf "build process completed - sunxi-tools programs are archived in: ${PACKAGES_DIR}/sunxi-tools-mingw64.zip.\n"
