#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $BASH_SOURCE)

# Absolute path this script is in. /home/user/bin
SCRIPTPATH=$(dirname $SCRIPT)
# Copyright (c) 2017-2021, Éric Périé
# 
#  SPDX-License-Identifier: BSD-3-Clause
# 
# Script for building a mingw64 version of sunxi-tools on Ubuntu 16.04.
#

# terminate on error
set -e

CROSS_COMPILE=/usr/bin/x86_64-w64-mingw32-

DTC_VERSION=1.6.0
LIBYAML_VERSION=0.2.5
SYSROOT=${SCRIPTPATH}/sysroot

do_retrieve_libyaml()
{
  if  [ ! -f libyaml-${LIBYAML_VERSION}.tar.gz ]
  then
    wget http://pyyaml.org/download/libyaml/yaml-${LIBYAML_VERSION}.tar.gz
  fi
}

do_build_libyaml()
{

  rm -rf ${SCRIPTPATH}/yaml-${LIBYAML_VERSION}
  tar zxf ${SCRIPTPATH}/yaml-${LIBYAML_VERSION}.tar.gz -C ${SCRIPTPATH}

  pushd ${SCRIPTPATH}/yaml-${LIBYAML_VERSION}
  CROSS_COMPILE=x86_64-w64-mingw32- ./configure --host=x86_64-w64-mingw32 --prefix=${SCRIPTPATH}/sysroot
  CROSS_COMPILE=x86_64-w64-mingw32- make all install
  popd
}

do_retrieve_dtc()
{
  if [ ! -f dtc-${DTC_VERSION}.tar.gz ]
  then
    wget https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-${DTC_VERSION}.tar.gz
  fi
}

do_prepare()
{
  rm -rf dtc-${DTC_VERSION}
  tar zxf dtc-${DTC_VERSION}.tar.gz
  cp mingw-compat.? dtc-${DTC_VERSION}
  pushd dtc-${DTC_VERSION}
  patch -p1 < ../fnmatch.diff
  make clean
  make dtc-lexer.lex.c  dtc-parser.tab.c
  popd
}

do_build_dtc()
  {
  pushd dtc-${DTC_VERSION}
 ${CROSS_COMPILE}gcc -static -I${SYSROOT}/include -L${SYSROOT}/lib -UNO_YAML -D__USE_MINGW_ANSI_STDIO=1 -Dlstat=mingw_lstat -I. -Ilibfdt -o dtc.exe \
      dtc.c  checks.c  data.c dtc-lexer.lex.c dtc-parser.tab.c  livetree.c srcpos.c treesource.c util.c flattree.c fstree.c mingw-compat.c yamltree.c libfdt/*.c -lyaml
  ${CROSS_COMPILE}gcc -static -I${SYSROOT}/include -L${SYSROOT}/lib -UNO_YAML -Ilibfdt -o fdtdump.exe fdtdump.c util.c mingw-compat.c libfdt/*.c -lyaml
  ${CROSS_COMPILE}gcc -static -I${SYSROOT}/include -L${SYSROOT}/lib -UNO_YAML -Ilibfdt -o fdtoverlay.exe fdtoverlay.c util.c libfdt/*.c -lyaml
  ${CROSS_COMPILE}gcc -static -I${SYSROOT}/include -L${SYSROOT}/lib -UNO_YAML -Ilibfdt -o fdtget.exe fdtget.c util.c libfdt/*.c -lyaml
  ${CROSS_COMPILE}gcc -static -I${SYSROOT}/include -L${SYSROOT}/lib -UNO_YAML -Ilibfdt -o fdtput.exe fdtput.c util.c libfdt/*.c -lyaml
  ${CROSS_COMPILE}gcc -static -I${SYSROOT}/include -L${SYSROOT}/lib -UNO_YAML  -Ilibfdt -o convert-dtsv0.exe convert-dtsv0-lexer.lex.c util.c libfdt/*.c -lshlwapi -lyaml
  ${CROSS_COMPILE}strip *.exe
  popd
}

# main
#do_retrieve_libyaml
#do_build_libyaml
#do_retrieve_dtc
do_prepare
do_build_dtc
