#!/bin/bash
set -o pipefail
cd /root/aosp || exit 1
export GOMAXPROCS=4
source build/envsetup.sh
lunch twrp_r9plus-bp2a-eng || exit 1
mka -j4 adbd recoveryimage 2>&1 | tee build.log
