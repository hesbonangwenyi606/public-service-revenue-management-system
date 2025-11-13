#!/usr/bin/env bash
# display_payments.sh
LOG_FILE="/opt/psrm/logs/payment_status.log"

# ANSI color codes
GREEN="\033[92m"
RED="\033[91m"
YELLOW="\033[93m"
RESET="\033[0m"

echo "[3] Latest payment log entries (colored):"
echo "--------------------------------------------------"
echo -e "Timestamp                 Transaction ID  Status"
echo "--------------------------------------------------"

while read -r line; do
    ts=$(echo "$line" | awk '{print $1}')
    tx=$(echo "$line" | awk '{print $2}')
    status=$(echo "$line" | awk '{print $3}')
    case $status in
        COMPLETED) color=$GREEN ;;
        FAILED) color=$RED ;;
        PENDING) color=$YELLOW ;;
        *) color=$RESET ;;
    esac
    echo -e "$ts      $tx ${color}$status${RESET}"
done < "$LOG_FILE"

echo "--------------------------------------------------"
