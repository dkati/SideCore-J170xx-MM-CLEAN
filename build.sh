#!/bin/bash
# kernel build script by Tkkg1994 v0.4 (optimized from apq8084 kernel source)
# Modified by side / XDA Developers

VERSION_NUMBER=$(<build/version)

TOOLCHAIN_DIR=toolchain/bin/aarch64-linux-android-
TC=uber 
#stock/linaro/uber
THISDIR=`readlink -f .`;

KERNELNAME=SideCore

repack()
{
	cd build/zip
	FILENAME=SideCore-${VERSION_NUMBER}-[UNIFIED]-`date +"[%H-%M]-[%d-%m]-J710xx-MM"`.zip
	zip -r $FILENAME .;
	cd ../..
	cp -r build/zip/*.zip PRODUCT/$FILENAME
}
evo()
{
	distro_clean;
	echo "Copying toolchain..."
	if [ ! -d "toolchain" ]; then
		mkdir toolchain
	fi
	cp -r ../toolchains/$TC/aarch64-linux-android-4.9/* toolchain
	
	#Build pure zImage
	export CROSS_COMPILE=$TOOLCHAIN_DIR
	export ARCH=arm64
	make j7_2016_defconfig
	make -j4
	
	PRODUCTIMAGE="arch/arm64/boot/Image"
	if [ ! -f "$PRODUCTIMAGE" ]; then
		echo "build failed" 
		exit 0;
	fi
	
	#Get evo Ramdisk
	rm -rf build/proprietary/carliv/boot/*
	cp -r ramdisks/evo/* build/proprietary/carliv/boot
	
	cp -r arch/arm64/boot/Image build/proprietary/carliv/boot/boot.img-kernel
	
	cd build/proprietary/carliv
	./carliv_executable.sh
	cd ../../..
	cp -r build/proprietary/carliv/output/boot.img build/zip/boot.img
	
	
	
}

stock()
{
	echo "Building stock kernel..."
	echo "Copying toolchain..."
	if [ ! -d "toolchain" ]; then
		mkdir toolchain
	fi
	cp -r ../toolchains/$TC/aarch64-linux-android-4.9/* toolchain
	
	#Build pure zImage
	export CROSS_COMPILE=$TOOLCHAIN_DIR
	export ARCH=arm64
	make j7_2016_defconfig
	make -j4
	
	PRODUCTIMAGE="arch/arm64/boot/Image"
	if [ ! -f "$PRODUCTIMAGE" ]; then
		echo "build failed" 
		exit 0;
	fi
	
	#Get stock Ramdisk
	rm -rf build/proprietary/carliv/boot/*
	cp -r ramdisks/stock/* build/proprietary/carliv/boot
	
	cp -r arch/arm64/boot/Image build/proprietary/carliv/boot/boot.img-kernel
	
	cd build/proprietary/carliv
	./carliv_executable.sh
	cd ../../..
	
	#Copy stock image to our flashables
	cp -r build/proprietary/carliv/output/boot.img build/zip/stock/boot.img
	
	
}

distro_clean()
{
	echo "Distro cleaning"
	rm -rf build/proprietary/kernel_stats/boot.img-kernel
	rm -rf build/zip/boot.img
	rm -rf build/zip/*.zip
	rm -rf build/proprietary/carliv/output/*
	rm -rf build/proprietary/carliv/boot-dummy/*
	rm -rf build/proprietary/carliv/boot/boot.img-kernel
	rm -rf build/proprietary/carliv/boot/*
	make clean
	make ARCH=arm64 distclean
	rm -rf toolchain/*
	if [ ! -d "toolchain" ]; then
		mkdir toolchain
	fi
	
	cp -r ../toolchains/$TC/aarch64-linux-android-4.9/* toolchain
	
}
deep_clean()
{

	echo "Cleaning custom kernel files..."
	distro_clean;
	
	rm -rf build/zip/stock/*
	rm -rf PRODUCT/*.zip
	ccache -c 
	ccache -C
	
	rm -rf toolchain/*
	if [ ! -d "toolchain" ]; then
		mkdir toolchain
	fi
	cp -r ../toolchains/$TC/aarch64-linux-android-4.9/* toolchain
	
}
rerun()
{
	bash build.sh;
}
echo ""
echo "SideCore kernel for J710xx"
echo "1) Clean Workspace"
echo "2) Build stock kernel"
echo "3) Build evo"
echo "4) Repack kernels"
echo "5) One-Click process"
echo "6) Exit"
echo ""
read -p "Please select an option " prompt
echo ""
if [ $prompt == "1" ]; then
	deep_clean; 
	rerun;
elif [ $prompt == "2" ]; then
	stock;
	rerun;
elif [ $prompt == "3" ]; then
	evo; 
	rerun;
elif [ $prompt == "4" ]; then
	repack;
	rerun;
elif [ $prompt == "5" ]; then
	deep_clean;
	stock;
	evo;
	repack;
	rerun;
elif [ $prompt == "6" ]; then
	exit
fi


