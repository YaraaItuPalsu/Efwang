#!/bin/sh

DEFCONFIG="rvkernel/rvkernel_defconfig"
CLANGDIR="/root/clang"

#
rm -rf compile.log

#
mkdir -p out
mkdir out/RvKernel
#mkdir out/RvKernel/SE_Stock
#mkdir out/RvKernel/NSE_Stock
mkdir out/RvKernel/SE_OC
#mkdir out/RvKernel/NSE_OC


#
export KBUILD_BUILD_USER=yaraaitupalsu
export KBUILD_BUILD_HOST=ovaduraivu
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
CC="ccache clang" \
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

#SE Stock
#cp RvKernel/SE/* arch/arm64/boot/dts/qcom/
#cp RvKernel/STOCK/sdm845-v2.dtsi arch/arm64/boot/dts/qcom/
#cp RvKernel/STOCK/gpucc-sdm845.c drivers/clk/qcom/
#rve 2>&1 | tee -a compile.log
#if [ $? -ne 0 ]
#then
#    echo "Build failed"
#else
#    echo "Build succesful"
#    cp out/arch/arm64/boot/Image.gz-dtb out/RvKernel/SE_Stock/Image.gz-dtb
    
#    #NSE Stock
#    cp RvKernel/NSE/* arch/arm64/boot/dts/qcom/
#    cp RvKernel/STOCK/sdm845-v2.dtsi arch/arm64/boot/dts/qcom/
#    cp RvKernel/STOCK/gpucc-sdm845.c drivers/clk/qcom/
#    rve
#    if [ $? -ne 0 ]
#    then
#        echo "Build failed"
#    else
#        echo "Build succesful"
#        cp out/arch/arm64/boot/Image.gz-dtb out/RvKernel/NSE_Stock/Image.gz-dtb
        
        #SE Overclock
        cp RvKernel/SE/* arch/arm64/boot/dts/qcom/
        cp RvKernel/OC/sdm845-v2.dtsi arch/arm64/boot/dts/qcom/
        cp RvKernel/OC/gpucc-sdm845.c drivers/clk/qcom/
        rve
        if [ $? -ne 0 ]
        then
            echo "Build failed"
        else
            echo "Build succesful"
            cp out/arch/arm64/boot/Image.gz-dtb out/RvKernel/SE_OC/Image.gz-dtb
            
            #NSE Overclock
            #cp RvKernel/NSE/* arch/arm64/boot/dts/qcom/
            #cp RvKernel/OC/sdm845-v2.dtsi arch/arm64/boot/dts/qcom/
            #cp RvKernel/OC/gpucc-sdm845.c drivers/clk/qcom/
            #rve
            #if [ $? -ne 0 ]
            #then
            #    echo "Build failed"
            #else
            #    echo "Build succesful"
            #    cp out/arch/arm64/boot/Image.gz-dtb out/RvKernel/NSE_OC/Image.gz-dtb
            fi
        fi
    fi
fi

END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
