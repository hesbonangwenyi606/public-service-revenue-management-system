#!/usr/bin/env bash
# list_oracle_processes.sh
echo "Oracle-related processes:"
ps aux | egrep 'oracle|tnslsnr|pmon|smmon|smon|dbwr|lgwr' | grep -v grep || echo "No oracle processes found"
echo
echo "Top 10 memory-consuming processes (RSS):"
ps aux --sort=-rss | head -n 11