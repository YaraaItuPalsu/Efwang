#!/bin/bash

#
DEFCONFIG="rvkernel/rvkernel_defconfig"

# you can set you name or host name(optional)
export KBUILD_BUILD_USER=Radika
export KBUILD_BUILD_HOST=Rve27

#
CLANG_DIR="/workspace/RvKernel-Builder/clang-18"

#
export PATH="$CLANG_DIR/bin:$PATH"

MAKE="./makeparallel"

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

make -j$(nproc --all) O=out LLVM=1 ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee compile.log
