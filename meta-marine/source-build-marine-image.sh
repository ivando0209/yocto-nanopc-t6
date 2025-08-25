#!/bin/bash

export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && export LC_CTYPE=en_US.UTF-8

. poky/buildtools/environment-setup-x86_64-pokysdk-linux

python poky/scripts/install-buildtools

if [ ! -d build-marine ]; then
  mkdir build-marine
fi

cp -rfv meta-marine/build-conf/* build-marine/conf/

source poky/oe-init-build-env build-marine

echo "bitbake core-image-minimal"

