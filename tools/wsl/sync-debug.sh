#!/bin/bash
cd /root/aosp || exit 1
echo '--- sync.log tail ---'
tail -c 20000 sync.log | tr '\r' '\n' | tail -50
echo '--- libcap ls-remote ---'
timeout 30 git ls-remote https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/external/libcap 2>&1 | head -5
echo '--- libbrillo ls-remote ---'
timeout 30 git ls-remote https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/external/libbrillo 2>&1 | head -5
echo '--- project dirs ---'
ls -ld external/libcap external/libbrillo 2>&1
echo '--- git fetch manual ---'
cd external/libcap 2>/dev/null && timeout 40 git fetch --depth=1 origin tag android-16.0.0_r1 2>&1 | tail -10
