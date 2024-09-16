#!/bin/bash
#Script to build buildroot configuration
#Author: Siddhant Jajoo

source shared.sh

EXTERNAL_REL_BUILDROOT=../base_external
git submodule init
git submodule sync
git submodule update

set -e 
cd `dirname $0`

if [ ! -e buildroot/.config ]
then
	echo "MISSING BUILDROOT CONFIGURATION FILE"

	if [ -e ${AESD_MODIFIED_DEFCONFIG} ]
	then
		echo "USING ${AESD_MODIFIED_DEFCONFIG}"
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT}
	else
		echo "Run ./save_config.sh to save this as the default configuration in ${AESD_MODIFIED_DEFCONFIG}"
		echo "Then add packages as needed to complete the installation, re-running ./save_config.sh as needed"
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_DEFAULT_DEFCONFIG}
	fi
else

  # Run the first make command and check for errors
  if ! make -C buildroot BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT}; then
    echo "First make command failed. Copying files..."

    # Copy the necessary files
    cp ./configure.ac buildroot/output/build/host-util-linux-2.37.4/
    cp ./pidfd-utils.h buildroot/output/build/host-util-linux-2.37.4/include

    echo "Files copied. Running make again..."

    # Run the make command again
    if ! make -C buildroot BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT}; then
        echo "Second make command failed. Exiting."
        exit 1
    else
        echo "Second make command succeeded."
    fi
  else
    echo "First make command succeeded. No need to run the second make command."
  fi

fi
