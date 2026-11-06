#!/bin/bash
cd /root/aosp || exit 1
for p in 5965 6641 6643 6650 7144 7145 7210 7213; do kill -9 "$p" 2>/dev/null || true; done
pkill -9 -f 'soong_build' 2>/dev/null || true
pkill -9 -f 'soong_ui' 2>/dev/null || true
sleep 2
mkdir -p /root/pruned
for d in art cts libcore development sdk test platform_testing tools; do
  [ -d "$d" ] && mv "$d" /root/pruned/ 2>/dev/null || true
done
for d in apps providers services screensavers wallpapers inputmethods; do
  [ -d "packages/$d" ] && mv "packages/$d" /root/pruned/packages_$d 2>/dev/null || true
done
rm -rf out/soong out/.module_paths
echo '--- remaining top ---'
ls -1 | head -30
echo '--- pruned ---'
du -sh /root/pruned 2>/dev/null
