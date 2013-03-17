#!/bin/bash
#set -o nounset
set -o errexit

PARALELLISM=$(nproc)
BUILD_TARGET="content_shell_apk"

if [ ! -n "${CHROMIUM_ANDROID-}" ]; then
	echo "Environment is not set up correctly!"
	exit 1
fi

ROOT_DIR=${CHROMIUM_ANDROID}
PARALELLISM=$(nproc)
BUILD_TARGET="content_shell_apk"

update() {
	cd ${ROOT_DIR}
	gclient sync
}

clean() {
	cd ${ROOT_DIR}/src
	rm -rf out/
	mkdir out/
}

build() {
	cd ${ROOT_DIR}/src
	gclient runhooks
	. ./build/android/envsetup.sh 
	android_gyp
	ninja -C out/Release -j${PARALELLISM} ${BUILD_TARGET}
}


# do it
update
clean
build
