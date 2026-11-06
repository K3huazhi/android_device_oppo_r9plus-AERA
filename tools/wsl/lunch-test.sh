#!/bin/bash
set -o pipefail
cd /root/aosp || exit 1
source build/envsetup.sh
lunch twrp_r9plus-bp2a-eng 2>&1 | tail -60
