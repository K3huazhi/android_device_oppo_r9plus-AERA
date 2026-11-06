#!/bin/bash
set -e
python3 /mnt/a/OPPOR9PlustmA/tools/wsl/merge-manifests.py
cd /root/aosp
cat > .repo/manifest.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <include name="merged.xml" />
</manifest>
EOF
rm -rf .repo/local_manifests
repo manifest -o manifest-resolved.xml 2>&1 | tail -15
echo '---COUNT---'
grep -c 'project path=' manifest-resolved.xml
echo '---REMOTES---'
grep '<remote' manifest-resolved.xml | head
