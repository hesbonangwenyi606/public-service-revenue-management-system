#!/bin/bash
# demo_psrm_enhanced.sh - Enhanced PSRM demo for video recording

API_URL="https://psrm.local/api/payments"
LOG_FILE="/opt/psrm/logs/payment_status.log"

echo "===================================="
echo "  PSRM Demo Script (Enhanced Version)"
echo "===================================="
echo

# 1) Check API health
echo "[1] Checking API health..."
curl -k https://psrm.local/health | jq .
echo
sleep 1

# 2) Simulate multiple payments with delays
echo "[2] Simulating payments..."
PAYMENTS=(50.00 75.00 120.50 250.00)
for amt in "${PAYMENTS[@]}"; do
    echo "Simulating payment: $amt"
    sudo -u psrm_admin bash -c "/opt/psrm/scripts/simulate_payment.sh $API_URL $amt"
    sleep 2  # wait 2 seconds between payments for clarity
done
echo

# 3) Display the latest 5 payment log entries in a nice table
echo "[3] Latest payment log entries:"
echo "--------------------------------------------------"
printf "%-25s %-15s %-10s\n" "Timestamp" "Transaction ID" "Status"
echo "--------------------------------------------------"
sudo tail -n 5 "$LOG_FILE" | awk -F'\t' '{printf "%-25s %-15s %-10s\n", $1, $2, $3}'
echo "--------------------------------------------------"
echo

echo "=== Demo Complete ==="
