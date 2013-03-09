#!/bin/bash
set -o nounset
set -o errexit

if [ ! -n "${ARMTOOLS-}" ]; then
	echo "Environment has not been set up!"
	exit 1
fi

clean() {
	cd ${NODEWEBKITARM}
	rm -rf src/out/
}

config() {

	if [ ! -d "${NODEWEBKITARM}" ]; then
		echo "Could not find the node-webkit source directory!"
		exit 1
	fi

	cd ${NODEWEBKITARM}

	if [ ! -e ".gclient" ]; then
		echo "Could not find the required .gclient file!"
		exit 1
	fi

	if [ "$(which gclient)" = "" ]; then
		echo "Could not find gclient, are depot_tools installed?"
		exit 1
	fi

	readonly SYSROOT="${NODEWEBKITARM}/src/arm-sysroot/"
	if [ ! -d ${SYSROOT} ]; then
		echo "The arm sysroot could not be found!"
		exit 1
	fi

	readonly PARALLELISM=$(nproc)
	
	export GYP_DEFINES=" \
component=static_library \
target_arch=arm \
armv7=1 \
arm_thumb=1 \
arm_neon=0 \
disable_nacl=1 \
werror= \
fastbuild=1 \
linux_use_tcmalloc=0 \
linux_breakpad=0 \
linux_use_gold_binary=0 \
linux_use_gold_flags=0 \
chromeos=0 \
use_aura=0 \
use_ash=0 \
v8_use_snapshot=0 \
disable_ftp_support=1 \
safe_browsing=0 \
enable_printing=0 \
v8_use_snapshot=0 \
enable_themes=0 \
file_manager_extension=0 \
remoting=0 \
enable_extensions=0 \
enable_themes=0 \
enable_app_list=0 \
notifications=0 \
enable_language_detection=0 \
enable_automation=0 \
configuration_policy=0 \
toolkit_views=0 \
toolkit_uses_gtk=0 \
input_speech=0 \
enable_google_now=0 \
enable_background=0 \
enable_task_manager=0 \
enable_plugin_installation=0 \
enable_plugins=0 \
use_glib=0 \
use_x11=0 \
use_nss=0 \
use_gnome_keyring=0 \
enable_webrtc=0 \
linux_use_libgps=0 \
use_system_libjpeg=1 \
disable_nacl_untrusted=1 \
icu_use_data_file_flag=1 \
use_system_bzip2=1 \
use_system_libxml=1 \
use_system_sqlite=1 \
p2p_apis=0 \
"
     	export GYP_DEFINES="target_arch=arm"
	
	export CXX=arm-linux-gnueabi-g++
	export CC=arm-linux-gnueabi-gcc
	export AR=arm-linux-gnueabi-ar
	export AS=arm-linux-gnueabi-as
	export RANLIB=arm-linux-gnueabi-ranlib
	export CXX_host=g++
	export CC_host=gcc
	export GYP_DEFINES

	gclient runhooks
}

# build without NACL support
make-nodewebkit() {
	cd ${NODEWEBKITARM}/src/
	set -x
	make BUILDTYPE=Release -j ${PARALLELISM} nw $*
}

# build with NACL support
make-nacl() {
	cd ${NODEWEBKITARM}/src/
	set -x
	make-chrome nacl_helper nacl_helper_bootstrap $*
}

package() {
  cd ${NODEWEBKITARM}/src/
  OUT=out/Release
  FILEPATH="${OUT}/nodewebkit-arm-$(date +%Y%m%d).tar.gz"
  rm -rf ${OUT}/nodewebkit-arm
  mkdir ${OUT}/nodewebkit-arm
  cp -r ${OUT}/nw \
     ${OUT}/lib*.so \
     ${OUT}/*.pak \
     ${OUT}/nodewebkit-arm
  tar cfvz "${FILEPATH}" -C ${OUT} nodewebkit-arm
  echo "NodeWebkitArm packaged in ${FILEPATH}"
}

# begin
config
clean
make-nodewebkit
package
