#!/bin/bash
cd /root/aosp || exit 1
pkill -9 -f 'soong_build' 2>/dev/null || true
pkill -9 -f 'soong_ui' 2>/dev/null || true
pkill -9 -f 'build.sh' 2>/dev/null || true
sleep 2
mkdir -p /root/pruned2/modules
# Keep the two AERA-patched modules that recovery actually uses.
[ -d packages/modules/adb ] && mv packages/modules/adb /root/pruned2/modules/adb
[ -d packages/modules/Connectivity ] && mv packages/modules/Connectivity /root/pruned2/modules/Connectivity
for d in art libcore dalvik libnativehelper cts test development sdk tools; do
  [ -d "$d" ] && mv "$d" /root/pruned2/ 2>/dev/null || true
done
[ -d frameworks/base ] && mv frameworks/base /root/pruned2/frameworks_base
[ -d packages ] && mv packages /root/pruned2/packages
mkdir -p packages/modules
[ -d /root/pruned2/modules/adb ] && mv /root/pruned2/modules/adb packages/modules/adb
[ -d /root/pruned2/modules/Connectivity ] && mv /root/pruned2/modules/Connectivity packages/modules/Connectivity
rm -rf out/soong out/.module_paths
echo '--- top ---'
ls -1
echo '--- packages ---'
find packages -maxdepth 2 -type d 2>/dev/null | head
echo '--- pruned2 ---'
du -sh /root/pruned2 2>/dev/null
