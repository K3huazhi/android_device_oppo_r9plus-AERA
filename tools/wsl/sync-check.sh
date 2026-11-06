#!/bin/bash
cd /root/aosp || exit 1
echo '--- repo help ---'
repo help sync 2>&1 | grep -E 'retry|jobs|force-sync|no-clone' | head -30
echo '--- processes ---'
ps -eo pid,etime,pcpu,args | grep -E 'repo|git ' | grep -v grep | head -20
echo '--- size ---'
du -sh /root/aosp
df -h /root/aosp
