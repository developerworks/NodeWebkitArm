NodeWebkitArm
=============

A group of scripts to aid in building nodewebkit on linux for target architecture ARM, and also Chromium for Android

For use on stock Ubuntu 12.04 LTS systems

Building nodewebkit-arm is easy:

1. setup platform environment with ./install-platform-env.sh (only ever needs to be done once!)

2. install nodewebkit-arm dependencies with ./install-node-webkit-arm-deps.sh

3. build node-webkit arm with ./build-nodewebkitarm.sh


You can also build chromium for android this way:

1. setup platform environment with ./install-platform-env.sh (only ever needs to be done once!)

2. install chromium-android dependencies with ./install-chromium-android-deps.sh

3. build chromium-android with ./build-chromium-android.sh
