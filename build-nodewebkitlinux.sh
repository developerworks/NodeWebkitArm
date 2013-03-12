#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${NODEWEBKITLINUX-}" ]; then
	echo "Environment has not been set up!"
	exit 1
fi

ROOT_DIR="${NODEWEBKITLINUX}"
BUILD_TARGET="nw"

clean() {
	cd ${ROOT_DIR}/src
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

	 export GYP_GENERATORS='ninja'

}

# build without NACL support
build() {
	cd ${ROOT_DIR}/src/
    gclient runhooks --force
    ./build/gyp_chromium -Dwerror=
	make BUILDTYPE=Release -j ${PARALLELISM} ${BUILD_TARGET}
}

# begin
config
clean
build
package
