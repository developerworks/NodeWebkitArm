#!/bin/bash
#
# NOTE: DOES NOT INCLUDE INSTALLING ORACLE JDK!!!!
# THIS MUST BE DONE MANUALLY BECAUSE ORACLE SUCK.
#
set -o nounset
set -o errexit

if [ ! -n "${ARMTOOLS-}" ]; then
        echo "ARM TOOLS are not installed."
        exit 1
fi

# required for build
# install & update software
declare -a pkg_req=(lib32z1-dev)
packages=""
echo "Checking for missing dependencies..."
for pkg in "${pkg_req[@]}"; do
        res=$(aptitude search "~i^${pkg}\$")
        if [ "$res" = "" ]; then
                packages="$packages $pkg"
        else
                echo " - $pkg"
        fi
done
if [ "$packages" != "" ]; then 
        sudo apt-get update
        sudo apt-get install $packages -y
fi

if [ ! -n "${CHROMIUM_ANDROID-}" ]; then
	CHROMIUM_ANROID="${ARMTOOLS_SOURCES}/chromium-android"
	echo "export CHROMIUM_ANDROID=${CHROMIUM_ANROID}" >> ~/.bash_profile
fi

if [ ! -d "${CHROMIUM_ANDROID}" ]; then
	mkdir ${CHROMIUM_ANDROID}
fi
cd ${CHROMIUM_ANDROID}

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
]
target_os = ["android"]' > .gclient 
fi

gclient sync
