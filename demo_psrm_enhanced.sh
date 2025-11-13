#!/bin/bash

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Determine host URL
if ping -c 1 psrm.local &>/dev/null; then
    HOST="https://psrm.local"
else
    echo "[!] psrm.local not resolvable, falling back to 127.0.0.1"
    HOST="http://127.0.0.1:5000"
fi

API_URL="$HOST/api/payments"
LOG_DIR="/opt/psrm/logs"
LOG_FILE="$LOG_DIR/payment_status.log"

# Ensure logs directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "[i] Creating logs directory: $LOG_DIR"
    sudo mkdir -p "$LOG_DIR"
    sudo chown psrm_admin:psrm_admin "$LOG_DIR"
    sudo chmod 750 "$LOG_DIR"
fi

# Ensure payment log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "[i] Creating payment log file: $LOG_FILE"
    sudo touch "$LOG_FILE"
    sudo chown psrm_admin:psrm_admin "$LOG_FILE"
    sudo chmod 660 "$LOG_FILE"
fi

echo "===================================="
echo "  PSRM Demo Script (Enhanced Version)"
echo "===================================="
echo

# 1) Check API health
echo "[1] Checking API health..."
curl -k "$HOST/health" | jq .
echo
sleep 1

# Function to display a progress bar
show_progress() {
    local duration=$1
    local elapsed=0
    local bar_length=30
    while [ $elapsed -le $duration ]; do
        percent=$((elapsed * 100 / duration))
        filled=$((elapsed * bar_length / duration))
        empty=$((bar_length - filled))
        printf "\r["
        for ((i=0;i<filled;i++)); do printf "#"; done
        for ((i=0;i<empty;i++)); do printf "-"; done
        printf "] %d%%" "$percent"
        sleep 1
        ((elapsed++))
    done
    echo
}

# 2) Simulate multiple payments with progress bar
echo "[2] Simulating payments..."
PAYMENTS=(50.00 75.00 120.50 250.00)
for amt in "${PAYMENTS[@]}"; do
    echo "Simulating payment: $amt"
    # Run the payment in background
    sudo -u psrm_admin /opt/psrm/scripts/simulate_payment.sh "$API_URL" "$amt" &
    show_progress 3  # 3-second progress bar for each payment
done
echo

# 3) Display the latest 5 payment log entries with colors
echo "[3] Latest payment log entries:"
echo "--------------------------------------------------"
printf "%-25s %-15s %-10s\n" "Timestamp" "Transaction ID" "Status"
echo "--------------------------------------------------"
sudo -u psrm_admin tail -n 5 "$LOG_FILE" | awk -F'\t' -v RED="$RED" -v YELLOW="$YELLOW" -v GREEN="$GREEN" -v NC="$NC" '{
    status=$3
    color=NC
    if (status=="FAILED") color=RED
    else if (status=="PENDING") color=YELLOW
    else if (status=="SUCCESS") color=GREEN
    printf "%-25s %-15s %s%-10s%s\n", $1, $2, color, status, NC
}'
echo "--------------------------------------------------"
echo
echo "=== Demo Complete ==="
