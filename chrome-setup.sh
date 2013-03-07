#!/bin/bash
set -o nounset
set -o errexit

#@ The typical usage for this tool is:
#@
#@ Install cross toolchain (do this only once per system)
#@
#@  build/install-build-deps.sh --arm
#@
#@  you may also want to:
#@   build/install-build-deps.sh
#@   build/linux/install-arm-sysroot.py (should already be done by hooks)
   #@   sudo apt-get install g++-multilib  gcc-multilib
#@
#@
#@  build chrome with the cross toolchain
#@  chrome-setup.sh configure-chrome
#@  chrome-setup.sh make-chrome
#@  chrome-setup.sh make-nacl    (optional)
#@  chrome-setup.sh package-chrome
#@  now copy the chrome tarball (chrome-arm.tgz) to your are device


readonly SYSROOT=$(pwd)/arm-sysroot
readonly PARALLELISM=20
readonly GYP_DEFINES="\
  target_arch=arm \
"

#@
#@
configure-chrome() {
  [ ! -d ${SYSROOT} ] && exit "arm root not found (run install-build-deps.sh --a
     rm)"
  export CXX=arm-linux-gnueabi-g++
  export CC=arm-linux-gnueabi-gcc
  export AR=arm-linux-gnueabi-ar
  export AS=arm-linux-gnueabi-as
  export RANLIB=arm-linux-gnueabi-ranlib
  export CXX_host=g++
  export CC_host=gcc
  export GYP_DEFINES
  # note this reads GYP_DEFINES
  gclient runhooks
}


build-targets() {
  [ ! -d ${SYSROOT} ] && exit "arm root not found"
  # $CXX should have been baked into both the ninja
  # files and the Makefiles by this time, but due
  # to several issues/bugs we need to set CXX during
  # the build too.
  # Ninja needs it since ld_bfd.py reads this env var
  # and ninja doesn't export it.
  # Make seems to need it otherwise it defines the
  # linker command incorrectly.
  # TODO(sbc): remove this
  export CXX=arm-linux-gnueabi-g++

  if [ "${GYP_GENERATORS:=}" == "ninja" ]; then
    set -x
    ninja -C ${GYP_GENERATOR_OUTPUT:=.}/out/Release $*
  else
    set -x
    make BUILDTYPE=Release -j ${PARALLELISM} $*
  fi
}

#@
#@ Make chrome binaries (pass -v, or V=99 in you
#@ want verbosity in make/ninja respectively.
make-chrome() {
  build-targets chrome $*
}

#@
#@ Make nacl binaries (pass -v, or V=99 in you
#@ want verbosity in make/ninja respectively.
make-nacl() {
  build-targets nacl_helper nacl_helper_bootstrap $*
}


package-chrome() {
  local OUT=${GYP_GENERATOR_OUTPUT:=.}/out/Release
  rm -rf ${OUT}/chrome-arm
  mkdir ${OUT}/chrome-arm
  cp -r ${OUT}/chrome \
     ${OUT}/lib*.so \
     ${OUT}/nacl_irt_*.nexe \
     ${OUT}/nacl_ipc_*.nexe \
     ${OUT}/nacl_helper \
     ${OUT}/nacl_helper_bootstrap \
     ${OUT}/chrome.pak \
     ${OUT}/resources.pak \
     ${OUT}/chrome_100_percent.pak \
     ${OUT}/locales \
     ${OUT}/chrome-arm
  tar cfvz ${OUT}/chrome-arm.tgz -C ${OUT} chrome-arm
  echo "chrome packaged in chrome-arm.tgz"
}

######################################################################
# DISPATCH
######################################################################
Usage() {
  egrep "^#@" $0 | cut --bytes=3-
}


if [[ $# -eq 0 ]] ; then
  echo "you must specify a mode on the commandline:"
  echo
  Usage
  exit -1
elif [[ "$(type -t $1)" != "function" ]]; then
  echo "ERROR: unknown function '$1'." >&2
  echo "For help, try:"
  echo "    $0 help"
  exit 1
else
  "$@"
fi