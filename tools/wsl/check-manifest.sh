#!/bin/bash
set -u
cd /root/aosp || exit 1
grep -n 'platform/bionic' .repo/remove-minimal.xml .repo/manifests/remove-minimal.xml 2>/dev/null || true
echo '--- twrp removes ---'
grep -n 'remove-project' .repo/manifests/twrp-default.xml | head -40
echo '--- local manifests ---'
ls -la .repo/local_manifests
