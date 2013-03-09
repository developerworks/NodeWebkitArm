#!/bin/bash
set -o nounset
set -o errexit

SCRIPT=$(pwd)
cd ../
ROOT=$(pwd)
SOURCES=${ROOT}/sources
TOOLS=${ROOT}/tools

# ensure directory structure consistency
if [ ! -d "${SCRIPT}" ]; then
	mkdir ${SCRIPT}
fi
if [ ! -d "${TOOLS}" ]; then
	mkdir ${TOOLS}
fi
if [ ! -d "${SOURCES}" ]; then
	mkdir ${SOURCES}
fi

# save to bash
echo "
export ARMTOOLS=1
export ARMTOOLS_ROOT=${ROOT}
export ARMTOOLS_SCRIPT=${SCRIPT}
export ARMTOOLS_TOOLS=${TOOLS}
export ARMTOOLS_SOURCES=${SOURCES}
PATH=\$PATH:\${ARMTOOLS_TOOLS}
export PATH
" >> ~/.bash_profile
source ~/.bash_profile
