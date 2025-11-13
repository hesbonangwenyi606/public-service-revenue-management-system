#!/bin/bash

# Color codes
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Path to your log file
LOG_FILE="/opt/psrm/logs/payment_status.log"

# Show the latest 10 log entries with colors
echo "[3] Latest payment log entries (colored):"
echo "--------------------------------------------------"
echo "Timestamp                 Transaction ID  Status"
echo "--------------------------------------------------"

sudo tail -n 10 "$LOG_FILE" | while read -r line; do
    status=$(echo "$line" | awk '{print $3}')
    if [ "$status" = "COMPLETED" ]; then
        echo -e "${GREEN}$line${RESET}"
    elif [ "$status" = "FAILED" ]; then
        echo -e "${RED}$line${RESET}"
    else
        echo -e "${YELLOW}$line${RESET}"
    fi
done

echo "--------------------------------------------------"
