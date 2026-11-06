#!/bin/bash
cd /root/aosp || exit 1
source build/envsetup.sh > /tmp/env.log 2>&1
rc=$?
echo "envsetup rc=$rc"
tail -60 /tmp/env.log
echo '--- type ---'
type mka 2>&1 || true
type lunch 2>&1 || true
echo "PATH=$PATH"
