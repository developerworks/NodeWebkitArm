#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${NODEWEBKITARM-}" ]; then
        echo "Environment is not correctly configured!"
        exit 1
fi

OUTPUT_PATH="${NODEWEBKITARM}/src/out/Release"
BUILD_TARGET="nw"
PACKAGE_PATH="${BUILD_TARGET}-package"
PACKAGE_FILE="${BUILD_TARGET}-arm-$(date +%Y%m%d).tar.gz"

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

	cp *.so ${PACKAGE_PATH}
	cp *.pak ${PACKAGE_PATH}
	cp ${BUILD_TARGET} ${PACKAGE_PATH}
	tar -zcvf ${PACKAGE_FILE} ${PACKAGE_PATH}

	echo "> Complete: packaged files into ${PACKAGE_FILE}"
}

# do it
clean
package
clean
