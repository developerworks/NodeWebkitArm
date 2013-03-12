#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${ARMTOOLS-}" ]; then
	echo "Environment has not been set up!"
	exit 1
fi

clean() {
	cd ${NODEWEBKITARM}
	rm -rf src/out/
}

config() {

	if [ ! -d "${NODEWEBKITARM}" ]; then
		echo "Could not find the node-webkit source directory!"
		exit 1
	fi

	cd ${NODEWEBKITARM}

	if [ ! -e ".gclient" ]; then
		echo "Could not find the required .gclient file!"
		exit 1
	fi

	if [ "$(which gclient)" = "" ]; then
		echo "Could not find gclient, are depot_tools installed?"
		exit 1
	fi

	readonly SYSROOT="${NODEWEBKITARM}/src/arm-sysroot/"
	if [ ! -d ${SYSROOT} ]; then
		echo "The arm sysroot could not be found!"
		exit 1
	fi

	readonly PARALLELISM=$(nproc)
	export GYP_DEFINES="target_arch=arm"
	export CXX=arm-linux-gnueabi-g++
	export CC=arm-linux-gnueabi-gcc
	export AR=arm-linux-gnueabi-ar
	export AS=arm-linux-gnueabi-as
	export RANLIB=arm-linux-gnueabi-ranlib
	export CXX_host=g++
	export CC_host=gcc
	export GYP_DEFINES

	gclient runhooks
}

build() {
	cd ${NODEWEBKITARM}/src/
	set -x
	make BUILDTYPE=Release -j ${PARALLELISM} nw $*
}

# begin
config
clean
build
