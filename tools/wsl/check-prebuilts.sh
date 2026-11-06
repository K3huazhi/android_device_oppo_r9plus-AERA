#!/bin/bash
cd /root/aosp || exit 1
echo '--- dirs ---'
ls -ld prebuilts/clang/host/linux-x86 prebuilts/rust prebuilts/sdk 2>&1
echo '--- processes ---'
ps -eo pid,etime,pcpu,pmem,args | grep -E 'prebuilts|repo sync' | grep -v grep | head -20
echo '--- log ---'
tail -c 3000 sync-missing.log 2>/dev/null | tr '\r' '\n' | tail -20
echo '--- disk ---'
df -h /root/aosp
