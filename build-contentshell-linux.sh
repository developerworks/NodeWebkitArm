#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${CHROMIUM_LINUX-}" ]; then
	echo "Environment is not set up correctly!"
	exit 1
fi

BUILDTARGET="content_shell"
OUT="${CHROMIUM_LINUX}/src/out/Release"

package() {
  PACKAGE_PATH="${OUT}/${BUILDTARGET}"
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
package
