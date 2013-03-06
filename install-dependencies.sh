#!/bin/bash
set -o nounset
set -o errexit

ROOT=$(pwd)
NODEWEBKIT=${ROOT}/node-webkit

# install & update software
sudo apt-get update
sudo apt-get install build-essential git subversion curl gcc-arm-linux-gnueabi -y

# may not be essential:
sudo apt-get build-dep chromium-browser -y

# depot_tools
if [ "$(which gclient)" = "" ]; then
	echo "Installing Google Depot Tools..."
  cd /usr/local/bin/
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  cd depot_tools
  echo "export DEPOT_TOOLS=${pwd}" >> ~/.bash_profile
  echo "PATH=\$PATH:${DEPOT_TOOLS}" >> ~/.bash_profile
fi

# setup node-webkit
if [ ! -d "${NODEWEBKIT}" ]; then
  mkdir ${NODEWEBKIT}
fi

cd ${NODEWEBKIT}

if [ ! -e ".gclient" ]; then
echo 'solutions = [
   { "name"        : "src",
     "url"         : "https://github.com/zcbenz/chromium.git@origin/node",
     "deps_file"   : ".DEPS.git",
     "managed"     : True,
     "custom_deps" : {
       "src/third_party/WebKit/LayoutTests": None,
       "src/chrome_frame/tools/test/reference_build/chrome": None,
       "src/chrome_frame/tools/test/reference_build/chrome_win": None,
       "src/chrome/tools/test/reference_build/chrome": None,
       "src/chrome/tools/test/reference_build/chrome_linux": None,
       "src/chrome/tools/test/reference_build/chrome_mac": None,
       "src/chrome/tools/test/reference_build/chrome_win": None,
     },
     "safesync_url": "",
   },
]' > .gclient
fi

# likely to fail sometimes, just re-run until complete:
gclient sync

chmod +x src/build/install-build-deps.sh
src/build/install-build-deps.sh --arm --no-prompt

# may not be essential: 
src/build/install-build-deps.sh --no-prompt
