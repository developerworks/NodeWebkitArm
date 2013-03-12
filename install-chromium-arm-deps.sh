#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${ARMTOOLS-}" ]; then
        echo "ARM TOOLS are not installed."
        exit 1
fi

# required for build
# install & update software
if [ ! -n "${CHROMIUM_ARM-}" ]; then
	CHROMIUM_ARM="${ARMTOOLS_SOURCES}/chromium-arm"
	echo "export CHROMIUM_ARM=${CHROMIUM_ARM}" >> ~/.bash_profile
fi

if [ ! -d "${CHROMIUM_ARM}" ]; then
	mkdir ${CHROMIUM_ARM}
fi
cd ${CHROMIUM_ARM}

if [ ! -e ".gclient" ]; then
echo 'solutions = [
  { "name"        : "src",
    "url"         : "https://src.chromium.org/chrome/trunk/src",
    "deps_file"   : "DEPS",
    "managed"     : True,
    "custom_deps" : {
       "src/third_party/WebKit/LayoutTests": None,
       "src/chrome_frame/tools/test/reference_build/chrome": None,
       "src/chrome_frame/tools/test/reference_build/chrome_win": None,
       "src/chrome/tools/test/reference_build/chrome": None,
       "src/chrome/tools/test/reference_build/chrome_linux": None,
       "src/chrome/tools/test/reference_build/chrome_mac": None,
       "src/chrome/tools/test/reference_build/chrome_win": None,
       "src/third_party/hunspell_dictionaries": None,
     },
     "safesync_url": "",
  },
]' > .gclient 
fi

# likely to fail sometimes, just re-run until complete:
gclient sync

# build dependencies
chmod +x src/build/install-build-deps.sh
src/build/install-build-deps.sh --arm --no-prompt

# arm sysroot
chmod +x src/build/linux/install-arm-sysroot.py
src/build/linux/install-arm-sysroot.py
