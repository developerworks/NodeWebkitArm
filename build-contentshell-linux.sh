#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${CHROMIUM_LINUX-}" ]; then
	echo "Environment is not set up correctly!"
	exit 1
fi

ROOT_DIR=${CHROMIUM_LINUX}
BUILDTARGET="content_shell"
OUT="${CHROMIUM_LINUX}/src/out/Release"

update() {
        cd ${ROOT_DIR}
        gclient sync
}

clean() {
	cd ${ROOT_DIR}/src
	rm -rf ${OUT}
	mkdir -p ${OUT}
}

build() {
	cd ${ROOT_DIR}/src
	export GYP_GENERATORS='ninja'
	gclient runhooks --force
	./build/gyp_chromium -Dwerror=
	ninja -C out/Release ${BUILDTARGET}
}

# do it
update
clean
build
