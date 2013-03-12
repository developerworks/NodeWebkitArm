#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${CHROMIUM_LINUX-}" ]; then
	echo "Environment is not set up correctly!"
	exit 1
fi

BUILDTARGET="chrome"
OUT="${CHROMIUM_LINUX}/src/out/Release"

clean() {
	cd ${CHROMIUM_LINUX}/src
	rm -rf ${OUT}
	mkdir -p ${OUT}
}

build() {
	cd ${CHROMIUM_LINUX}/src
	export GYP_GENERATORS='ninja'
	gclient runhooks --force
	./build/gyp_chromium -Dwerror=
	ninja -C out/Release ${BUILDTARGET}
}

# do it
clean
build
