#!/bin/bash

if [ ! -n "${CHROMIUM_LINUX-}" ]; then
	echo "Environment is not set up correctly!"
	exit 1
fi

cd ${CHROMIUM_LINUX}
rm -rf src/out/
gclient sync
cd src

export GYP_GENERATORS='ninja'

rm -rf out/
mkdir -p "out/Release"

gclient runhooks --force
./build/gyp_chromium -Dwerror=
ninja -C out/Release content_shell
