#!/bin/bash
set -o nounset
set -o errexit

NODEWEBKIT="$(pwd)/node-webkit"

config() {

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

	readonly SYSROOT="${NODEWEBKIT}/src/arm-sysroot/"
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
}

# build without NACL support
make-nodewebkit() {
	cd ${NODEWEBKIT}/src/
	set -x
	make BUILDTYPE=Release -j ${PARALLELISM} nw $*
}

# build with NACL support
make-nacl() {
	cd ${NODEWEBKIT}/src/
	set -x
	make-chrome nacl_helper nacl_helper_bootstrap $*
}

package() {
  cd ${NODEWEBKIT}/src/
  OUT=out/Release
  FILEPATH="${OUT}/nodewebkit-arm-$(date +%Y%m%d).tar.gz"
  rm -rf ${OUT}/nodewebkit-arm
  mkdir ${OUT}/nodewebkit-arm
  cp -r ${OUT}/nw \
     ${OUT}/lib*.so \
     ${OUT}/*.pak \
     ${OUT}/nodewebkit-arm
  tar cfvz "${FILEPATH}" -C ${OUT} nodewebkit-arm
  echo "NodeWebkitArm packaged in ${FILEPATH}"
}

# begin
config
make-nodewebkit
package