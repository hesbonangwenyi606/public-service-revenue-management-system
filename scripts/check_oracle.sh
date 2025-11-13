#!/usr/bin/env bash
# check_oracle.sh
# Cron-run script to verify Oracle is running and restart if necessary.
set -euo pipefail
LOG="/opt/psrm/logs/oracle_watch.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Try systemctl first
if systemctl list-units --type=service | grep -qi oracle; then
  if systemctl is-active --quiet oracle-xe || systemctl is-active --quiet oracle.service; then
    echo "${TIMESTAMP} Oracle service active" >> "${LOG}"
    exit 0
  else
    echo "${TIMESTAMP} Oracle service not active. Attempting restart..." >> "${LOG}"
    if sudo systemctl restart oracle-xe || sudo systemctl restart oracle.service; then
      echo "${TIMESTAMP} Oracle restarted via systemctl" >> "${LOG}"
      exit 0
    else
      echo "${TIMESTAMP} Failed to restart Oracle via systemctl" >> "${LOG}"
      exit 1
    fi
  fi
fi

# Fallback: check for oracle processes (tnslsnr, ora_pmon, etc)
if pgrep -f ora_pmon >/dev/null 2>&1; then
  echo "${TIMESTAMP} Oracle process detected" >> "${LOG}"
  exit 0
else
  echo "${TIMESTAMP} No Oracle process detected. Attempting to start listener and database (may require ORACLE_HOME)" >> "${LOG}"
  # Attempt startup with sqlplus if available
  if command -v sqlplus >/dev/null 2>&1; then
    # This requires appropriate environment variables and privileges
    echo "startup" | sqlplus / as sysdba >> "${LOG}" 2>&1 || true
    echo "${TIMESTAMP} Attempted 'startup' via sqlplus" >> "${LOG}"
  else
    echo "${TIMESTAMP} sqlplus not available; cannot attempt startup." >> "${LOG}"
  fi
fi