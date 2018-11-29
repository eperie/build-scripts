#!/bin/bash
CROSS_COMPILE=/usr/bin/x86_64-w64-mingw32-
set -e

DTC_VERSION=1.4.7
git clone https://git.kernel.org/pub/scm/utils/dtc/dtc.git
cp mingw-compat.c dtc
pushd dtc
git checkout v${DTC_VERSION}
make clean
make dtc-lexer.lex.c  dtc-parser.tab.c

${CROSS_COMPILE}gcc -D__USE_MINGW_ANSI_STDIO=1 -Dlstat=mingw_lstat -I. -Ilibfdt -o dtc.exe dtc.c  checks.c  data.c dtc-lexer.lex.c dtc-parser.tab.c  livetree.c srcpos.c treesource.c util.c flattree.c fstree.c mingw-compat.c libfdt/*.c
${CROSS_COMPILE}gcc -Ilibfdt -o fdtdump.exe fdtdump.c util.c mingw-compat.c libfdt/*.c
${CROSS_COMPILE}gcc -Ilibfdt -o fdtoverlay.exe fdtoverlay.c util.c libfdt/*.c
${CROSS_COMPILE}gcc -Ilibfdt -o fdtget.exe fdtget.c util.c libfdt/*.c
${CROSS_COMPILE}gcc -Ilibfdt -o fdtput.exe fdtput.c util.c libfdt/*.c
#${CROSS_COMPILE}gcc -Ilibfdt -o convert-dtsv0.exe convert-dtsv0-lexer.lex.c util.c libfdt/*.c -lshlwapi

popd
