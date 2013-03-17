#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${CHROMIUM_ANDROID-}" ]; then
        echo "Environment is not correctly configured!"
        exit 1
fi

ROOT=$(pwd)
OUTPUT_PATH="${CHROMIUM_ANDROID}/src/out/Release/apks"
BUILD_TARGET="content_shell"
PACKAGE_PATH="${BUILD_TARGET}-android"
PACKAGE_FILE="${BUILD_TARGET}-android-$(date +%Y%m%d).tar.gz"

clean() {
	cd ${OUTPUT_PATH}

	if [ -d "${PACKAGE_PATH}" ]; then
                rm -rf ${PACKAGE_PATH}
        fi
}

package() {
	cd ${OUTPUT_PATH}

	if [ -d "${PACKAGE_PATH}" ]; then
		echo "${PACKAGE_PATH} already exists."
	fi

	mkdir ${PACKAGE_PATH}

	cp *.apk ${PACKAGE_PATH}
	cp ${BUILD_TARGET} ${PACKAGE_PATH}
	tar -zcvf ${PACKAGE_FILE} ${PACKAGE_PATH}
	mv ${PACKAGE_FILE} "${ROOT}/${PACKAGE_FILE}"
	echo "> Complete: packaged files into ${PACKAGE_FILE}"
}

# do it
clean
package
clean
