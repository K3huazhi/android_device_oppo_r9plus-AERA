#!/bin/bash
cd /root/aosp || exit 1
echo '--- repo processes ---'
ps -eo pid,etime,pcpu,args | grep -E 'repo sync|git-remote-https' | grep -v grep | head -20 || true
echo '--- clang ---'
ls -ld prebuilts/clang/host/linux-x86 2>&1 || true
echo '--- repo project ---'
ls -ld .repo/projects/prebuilts/clang 2>&1 || true
echo '--- disk ---'
df -h /root/aosp
