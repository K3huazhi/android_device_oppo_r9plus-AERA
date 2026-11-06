#!/bin/bash
cd /root/aosp || exit 1
echo '--- build.log tail ---'
tail -c 8000 build.log 2>/dev/null | tr '\r' '\n' | tail -50
echo '--- processes ---'
ps -eo pid,etime,pcpu,pmem,args | grep -E 'soong|ninja|mka|make|build.sh' | grep -v grep | head -20
echo '--- out ---'
ls -l out/target/product/r9plus/recovery.img 2>&1 || true
echo '--- mem ---'
free -h
