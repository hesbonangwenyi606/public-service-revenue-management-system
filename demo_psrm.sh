#!/bin/bash
# demo_psrm.sh - Quick demo for PSRM Flask + Nginx

API_URL="https://psrm.local/api/payments"
LOG_FILE="/opt/psrm/logs/payment_status.log"

echo "=== PSRM Demo Script ==="
echo

# 1) Check API health
echo "[1] Checking API health..."
curl -k https://psrm.local/health | jq .
echo

# 2) Simulate multiple payments
echo "[2] Simulating payments..."
PAYMENTS=(50.00 75.00 120.50 250.00)
for amt in "${PAYMENTS[@]}"; do
    echo "Simulating payment: $amt"
    sudo -u psrm_admin bash -c "/opt/psrm/scripts/simulate_payment.sh $API_URL $amt"
done
echo

# 3) Show the last 5 payment log entries
echo "[3] Latest payment logs:"
sudo tail -n 5 "$LOG_FILE"
echo

echo "=== Demo Complete ==="
