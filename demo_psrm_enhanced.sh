#!/bin/bash

# -----------------------------
# backup_db.sh
# -----------------------------
# Exports Oracle schema PSRM_DB to /opt/psrm/backups/
# Logs activities to /opt/psrm/logs/backup.log
# -----------------------------

# Set Oracle environment (adjust ORACLE_HOME and ORACLE_SID)
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE

BACKUP_DIR="/opt/psrm/backups"
LOG_FILE="/opt/psrm/logs/backup.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DUMP_FILE="$BACKUP_DIR/psrm_db_$TIMESTAMP.dmp"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Perform the export using expdp
# Replace PSRM_DB/password with actual username/password
expdp PSRM_DB/password@XE schemas=PSRM_DB directory=DATA_PUMP_DIR dumpfile=$(basename "$DUMP_FILE") logfile=backup_$TIMESTAMP.log

if [ $? -eq 0 ]; then
    echo "$(date '+%F %T') - Backup successful: $DUMP_FILE" >> "$LOG_FILE"
else
    echo "$(date '+%F %T') - Backup FAILED!" >> "$LOG_FILE"
fi
