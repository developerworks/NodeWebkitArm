#!/bin/bash

if [ ! -n "${CHROMIUM_ANDROID-}" ]; then
	echo "Environment is not set up correctly!"
	exit 1
fi

cd ${CHROMIUM_ANDROID}
rm -rf src/out/
gclient sync
cd src
. build/android/envsetup.sh
android_gyp
ninja -C out/Release -j$(nproc) content_shell_apk
