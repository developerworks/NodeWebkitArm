#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${CHROMIUM_ARM-}" ]; then
	echo "Environment has not been set up!"
	exit 1
fi

ROOT_DIR="${CHROMIUM_ARM}"
BUILD_TARGET="chrome"
OUTPUT_DIR="out/Release"
PACKAGE_PATH="${OUTPUT_DIR}/${BUILDTARGET}"

clean() {
	cd ${ROOT_DIR}/src/
	rm -rf out/
	mkdir out/
}

config() {

	if [ ! -d "${ROOT_DIR}" ]; then
		echo "Could not find the source directory!"
		exit 1
	fi

	cd ${ROOT_DIR}

	if [ ! -e ".gclient" ]; then
		echo "Could not find the required .gclient file!"
		exit 1
	fi

	if [ "$(which gclient)" = "" ]; then
		echo "Could not find gclient, are depot_tools installed?"
		exit 1
	fi

	readonly SYSROOT="${CHROMIUM_ARM}/src/arm-sysroot/"
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
	cd ${ROOT_DIR}/src/
	set -x
	make BUILDTYPE=Release -j${PARALLELISM} ${BUILD_TARGET}
}

package() {
  rm -rf ${PACKAGE_PATH}
  mkdir ${PACKAGE_PATH}
  cp -r ${PACKAGE_PATH} \
     ${OUT}/lib*.so \
     ${OUT}/nacl_irt_*.nexe \
     ${OUT}/nacl_ipc_*.nexe \
     ${OUT}/nacl_helper \
     ${OUT}/nacl_helper_bootstrap \
     ${OUT}/${BUILDTARGET}.pak \
     ${OUT}/resources.pak \
     ${OUT}/${BUILDTARGET}_100_percent.pak \
     ${OUT}/locales \
     ${OUT}/${BUILDTARGET}
  tar cfvz ${PACKAGE_PATH}.tgz -C ${PACKAGE_PATH} ${BUILDTARGET}
  echo "> Packaged build output into ${PACKAGE_PATH}.tgz"
}

# begin
clean
config
build
package
