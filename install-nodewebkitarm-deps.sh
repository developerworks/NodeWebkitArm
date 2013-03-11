#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${ARMTOOLS-}" ]; then
	echo "ARM TOOLS are not installed."
	exit 1
fi

# install & update software
declare -a pkg_req=(build-essential git subversion curl gcc-arm-linux-gnueabi)
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

# may not be essential:
#sudo apt-get build-dep chromium-browser -y

# depot_tools
if [ "$(which gclient)" = "" ]; then
  echo "Installing Google Depot Tools..."
  cd ${ARMTOOLS_TOOLS}
  if [ ! -d "depot_tools" ]; then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    cd depot_tools
  else 
    cd depot_tools
    git reset --hard HEAD
    git pull origin master
  fi
  echo "export DEPOT_TOOLS=$(pwd)" >> ~/.bash_profile
  echo "PATH=\$PATH:\${DEPOT_TOOLS}" >> ~/.bash_profile
  . ~/.bash_profile
fi

# setup node-webkit-arm
NODEWEBKITARM="${ARMTOOLS_SOURCES}/nodewebkit-arm"
if [ ! -d "${NODEWEBKITARM}" ]; then
	mkdir ${NODEWEBKITARM}
fi
echo "export NODEWEBKITARM=${NODEWEBKITARM}" >> ~/.bash_profile
cd ${NODEWEBKITARM}

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

# arm sysroot
src/build/linux/install-arm-sysroot.py 
