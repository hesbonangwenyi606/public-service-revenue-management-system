#!/bin/bash


# Use printf for reliable color output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

LOG_FILE="/opt/psrm/logs/payment_status.log"

echo -e "[3] Latest payment log entries (colored):"
echo "--------------------------------------------------"
echo "Timestamp                 Transaction ID  Status"
echo "--------------------------------------------------"

sudo tail -n 10 "$LOG_FILE" | while read -r line; do
    status=$(echo "$line" | awk '{print $3}')
    case "$status" in
        COMPLETED)
            printf "${GREEN}%s${RESET}\n" "$line"
            ;;
        FAILED)
            printf "${RED}%s${RESET}\n" "$line"
            ;;
        PENDING)
            printf "${YELLOW}%s${RESET}\n" "$line"
            ;;
        *)
            printf "%s\n" "$line"
            ;;
    esac
done

echo "--------------------------------------------------"
