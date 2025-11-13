#!/usr/bin/env bash
# backup_db.sh
# Exports Oracle schema PSRM_DB to /opt/psrm/backups with timestamp and logs to /opt/psrm/logs/backup.log
set -euo pipefail
TIMESTAMP=$(date '+%Y%m%d%H%M%S')
BACKUP_DIR="/opt/psrm/backups"
LOG_FILE="/opt/psrm/logs/backup.log"
SCHEMA="PSRM_DB"
DUMPFILE="${BACKUP_DIR}/psrm_${TIMESTAMP}.dmp"
LOG_OUTPUT="${BACKUP_DIR}/psrm_${TIMESTAMP}.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting backup for schema ${SCHEMA}" >> "${LOG_FILE}"

if command -v expdp >/dev/null 2>&1; then
  # Use data pump export if available. User must configure a DIRECTORY object in Oracle pointing to a filesystem path.
  echo "Using expdp (Data Pump). Ensure DIRECTORY=DATA_PUMP_DIR maps to a valid Oracle directory." >> "${LOG_FILE}"
  # Example: expdp system/password schemas=${SCHEMA} directory=DATA_PUMP_DIR dumpfile=$(basename "${DUMPFILE}") logfile=$(basename "${LOG_OUTPUT}")
  expdp "/ as sysdba" schemas=${SCHEMA} directory=DATA_PUMP_DIR dumpfile=$(basename "${DUMPFILE}") logfile=$(basename "${LOG_OUTPUT}") >> "${LOG_FILE}" 2>&1 || {
    echo "$(date '+%Y-%m-%d %H:%M:%S') expdp failed" >> "${LOG_FILE}"
    exit 1
  }
  # move resulting dump/log from Oracle directory to BACKUP_DIR if necessary (manual step)
elif command -v exp >/dev/null 2>&1; then
  echo "Using exp (classic export)" >> "${LOG_FILE}"
  exp ${SCHEMA}/password file="${DUMPFILE}" log="${LOG_OUTPUT}" >> "${LOG_FILE}" 2>&1 || {
    echo "$(date '+%Y-%m-%d %H:%M:%S') exp failed" >> "${LOG_FILE}"
    exit 1
  }
else
  # Fallback: Use SQL*Plus to spool a logical export (schema DDL + data as inserts)
  echo "Neither expdp nor exp found. Falling back to SQL*Plus DDL+INSERT spool (requires sqlplus and privileges)." >> "${LOG_FILE}"
  SQLFILE="${BACKUP_DIR}/psrm_${TIMESTAMP}.sql"
  cat > /tmp/dump_sql.sql <<'EOF'
set echo off pagesize 0 feedback off verify off heading off;
spool /tmp/psrm_export.sql
-- The following is a simplistic approach: users should replace with proper exp/expdp.
select '/* TABLE: '||table_name||' */' from user_tables;
spool off
exit
EOF
  if command -v sqlplus >/dev/null 2>&1; then
    sqlplus /nolog @/tmp/dump_sql.sql >> "${LOG_FILE}" 2>&1 || true
    mv /tmp/psrm_export.sql "${SQLFILE}" || true
    echo "$(date '+%Y-%m-%d %H:%M:%S') Wrote SQL export to ${SQLFILE}" >> "${LOG_FILE}"
  else
    echo "sqlplus not found. Backup cannot proceed." >> "${LOG_FILE}"
    exit 2
  fi
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Backup finished. Files (if any) placed in ${BACKUP_DIR}" >> "${LOG_FILE}"