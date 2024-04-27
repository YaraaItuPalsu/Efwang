#!/bin/sh

DEFCONFIG="rvkernel/rvkernel-ksu_defconfig"
CLANGDIR="/workspace/RvKernel-Builder/clang"

#
rm -rf out

#
mkdir -p out
mkdir out/RvKernel
mkdir out/RvKernel/SE
mkdir out/RvKernel/NSE


#
export KBUILD_BUILD_USER=Radika
export KBUILD_BUILD_HOST=Rve27
export PATH="$CLANGDIR/bin:$PATH"

#
make O=out ARCH=arm64 $DEFCONFIG

#
MAKE="./makeparallel"

#
START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

rve () {
make -j$(nproc --all) O=out LLVM=1 \
ARCH=arm64 \
CC=clang \
LD=ld.lld \
AR=llvm-ar \
AS=llvm-as \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
OBJDUMP=llvm-objdump \
STRIP=llvm-strip \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_ARM32=arm-linux-gnueabi-
}

#SE
cp RvKernel/SE/* arch/arm64/boot/dts/qcom/
rve | tee -a compile.log
if [ $? -ne 0 ]
then
    echo "Build failed"
else
    echo "Build succesful"
    cp out/arch/arm64/boot/Image.gz-dtb out/RvKernel/SE/Image.gz-dtb
    
    #NSE
    cp RvKernel/NSE/* arch/arm64/boot/dts/qcom/
    rve
    if [ $? -ne 0 ]
    then
        echo "Build failed"
    else
        echo "Build succesful"
        cp out/arch/arm64/boot/Image.gz-dtb out/RvKernel/NSE/Image.gz-dtb
    fi
fi

END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
