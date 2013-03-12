#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${ARMTOOLS-}" ]; then
	echo "ARM TOOLS are not installed."
	exit 1
fi

# install & update software
declare -a pkg_req=(build-essential git subversion curl)
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

# setup node-webkit-linux
NODEWEBKITLINUX="${ARMTOOLS_SOURCES}/nodewebkit-linux"
if [ ! -d "${NODEWEBKITLINUX}" ]; then
	mkdir ${NODEWEBKITLINUX}
fi
echo "export NODEWEBKITLINUX=${NODEWEBKITLINUX}" >> ~/.bash_profile
cd ${NODEWEBKITLINUX}

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

chmod +x src/build/install-build-deps.sh
src/build/install-build-deps.sh --no-prompt
