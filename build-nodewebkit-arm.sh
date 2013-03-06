#!/bin/bash
set -o nounset
set -o errexit

NODEWEBKIT=$(pwd)/node-webkit

build() {

	if [ ! -d "${NODEWEBKIT}" ]; then
		echo "Could not find the node-webkit source directory!"
		exit 1
	fi

	cd ${NODEWEBKIT}

	if [ ! -e ".gclient" ]; then
		echo "Could not find the required .gclient file!"
		exit 1
	fi

	if [ $(which gclient) = "" ]; then
		echo "Could not find gclient, are depot_tools installed?"
		exit 1
	fi

	readonly SYSROOT=$(pwd)/node-webkit/src/arm-sysroot
	if [ ! -d ${SYSROOT} ]; then
		echo "The arm sysroot could not be found!"
		exit 1
	fi

	readonly PARALLELISM=$(nproc)
	readonly GYP_DEFINES="\
	  target_arch=arm \
	"

	export CXX=arm-linux-gnueabi-g++
	export CC=arm-linux-gnueabi-gcc
	export AR=arm-linux-gnueabi-ar
	export AS=arm-linux-gnueabi-as
	export RANLIB=arm-linux-gnueabi-ranlib
	export CXX_host=g++
	export CC_host=gcc
	export GYP_DEFINES

	gclient runhooks
	make-chrome
}

make-chrome() {
	set -x
	make BUILDTYPE=Release -j ${PARALLELISM} nw $*
}

make-nacl() {
	make-chrome nacl_helper nacl_helper_bootstrap $*
}

package() {
  local OUT=${GYP_GENERATOR_OUTPUT:=.}/out/Release
  rm -rf ${OUT}/chrome-arm
  mkdir ${OUT}/chrome-arm
  cp -r ${OUT}/chrome \
     ${OUT}/lib*.so \
     ${OUT}/nacl_irt_*.nexe \
     ${OUT}/nacl_ipc_*.nexe \
     ${OUT}/nacl_helper \
     ${OUT}/nacl_helper_bootstrap \
     ${OUT}/chrome.pak \
     ${OUT}/resources.pak \
     ${OUT}/chrome_100_percent.pak \
     ${OUT}/locales \
     ${OUT}/chrome-arm
  tar cfvz ${OUT}/chrome-arm.tgz -C ${OUT} chrome-arm
  echo "chrome packaged in ${OUT}/chrome-arm/chrome-arm.tgz"
}

# begin
build
package