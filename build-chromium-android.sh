#!/bin/bash
#set -o nounset
set -o errexit

PARALELLISM=$(nproc)
BUILD_TARGET="content_shell_apk"

if [ ! -n "${CHROMIUM_ANDROID-}" ]; then
	echo "Environment is not set up correctly!"
	exit 1
fi

clean() {
	cd ${CHROMIUM_ANDROID}/src
	rm -rf out/
	mkdir out/
}

build() {
	cd ${CHROMIUM_ANDROID}/src
	gclient runhooks
	. ./build/android/envsetup.sh 
	android_gyp
	ninja -C out/Release -j${PARALELLISM} ${BUILD_TARGET}
}


# do it
clean
build
