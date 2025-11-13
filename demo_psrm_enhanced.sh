#!/bin/bash

# Demo PSRM Script (Enhanced) - works for your user without switching manually

# Determine host
if ping -c 1 psrm.local &>/dev/null; then
    HOST="https://psrm.local"
else
    echo "[!] psrm.local not resolvable, falling back to 127.0.0.1"
    HOST="http://127.0.0.1:5000"
fi

API_URL="$HOST/api/payments"
LOG_FILE="/opt/psrm/logs/payment_status.log"

echo "===================================="
echo "  PSRM Demo Script (Enhanced Version)"
echo "===================================="
echo

# 1) Check API health
echo "[1] Checking API health..."
curl -k "$HOST/health" | jq .
echo
sleep 1

# 2) Simulate multiple payments
echo "[2] Simulating payments..."
PAYMENTS=(50.00 75.00 120.50 250.00)
for amt in "${PAYMENTS[@]}"; do
    echo "Simulating payment: $amt"
    # Run simulate_payment.sh as psrm_admin internally
    sudo -u psrm_admin bash -c "/opt/psrm/scripts/simulate_payment.sh $API_URL $amt"
    sleep 2
done
echo

# 3) Display latest 5 payment log entries
echo "[3] Latest payment log entries:"
echo "--------------------------------------------------"
printf "%-25s %-15s %-10s\n" "Timestamp" "Transaction ID" "Status"
echo "--------------------------------------------------"
if sudo test -f "$LOG_FILE"; then
    sudo tail -n 5 "$LOG_FILE" | awk -F'\t' '{printf "%-25s %-15s %-10s\n", $1, $2, $3}'
else
    echo "[!] Payment log not found: $LOG_FILE"
fi
echo "--------------------------------------------------"
echo
echo "=== Demo Complete ==="
