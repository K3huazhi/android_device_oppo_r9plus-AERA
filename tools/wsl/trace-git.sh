#!/bin/bash
p=$(pgrep -f 'git-remote-https.*libcap' | head -1)
echo "PID=$p"
if [ -z "$p" ]; then
  p=$(pgrep -f 'git-remote-https' | head -1)
  echo "fallback PID=$p"
fi
[ -z "$p" ] && exit 1
echo '--- wchan ---'
cat /proc/$p/wchan 2>/dev/null || true
echo
echo '--- status ---'
grep -E 'State|Threads' /proc/$p/status 2>/dev/null || true
echo '--- fd ---'
ls -l /proc/$p/fd 2>/dev/null | tail -10 || true
echo '--- strace ---'
timeout 6 strace -f -p "$p" -e trace=network,read,write,poll,select,connect -s 100 2>&1 | tail -50 || true
