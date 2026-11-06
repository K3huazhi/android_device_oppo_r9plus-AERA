#!/bin/bash
cd /root/aosp || exit 1
echo '--- processes ---'
ps -eo pid,etime,pcpu,pmem,args | grep -E 'repo|git ' | grep -v grep | head -20
echo '--- log tail ---'
tail -c 3000 sync.log | tr '\r' '\n' | tail -30
echo '--- size ---'
du -sh /root/aosp 2>/dev/null
echo '--- dirs ---'
find /root/aosp -maxdepth 1 -mindepth 1 -type d | wc -l
echo '--- disk ---'
df -h /root/aosp
