#!/bin/bash

# --------------------------------------------
# PSRM Demo Script (Enhanced Version) - Auto /etc/hosts & NGINX check
# --------------------------------------------

HOSTNAME="psrm.local"
HOST_IP="127.0.0.1"
API_PORT=5000
API_URL=""
LOG_FILE="/opt/psrm/logs/payment_status.log"

# 1) Ensure /etc/hosts has psrm.local entry
if ! grep -q "$HOSTNAME" /etc/hosts; then
    echo "[!] $HOSTNAME not found in /etc/hosts, adding..."
    echo "$HOST_IP $HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
    echo "[+] Added $HOSTNAME -> $HOST_IP"
fi

# 2) Check NGINX status and start/reload if needed
if ! systemctl is-active --quiet nginx; then
    echo "[!] NGINX is not running. Attempting to start..."
    sudo systemctl start nginx
    sleep 2
    if systemctl is-active --quiet nginx; then
        echo "[+] NGINX started successfully"
    else
        echo "[!] Failed to start NGINX. Check 'sudo systemctl status nginx'"
    fi
else
    echo "[+] NGINX is already running. Reloading..."
    sudo systemctl reload nginx
fi

# 3) Determine protocol
if ping -c 1 $HOSTNAME &>/dev/null; then
    HOST="https://$HOSTNAME"
else
    echo "[!] $HOSTNAME still not resolvable, falling back to localhost HTTP"
    HOST="http://$HOST_IP:$API_PORT"
fi

API_URL="$HOST/api/payments"

echo "===================================="
echo "  PSRM Demo Script (Enhanced Version)"
echo "===================================="
echo

# 4) Check API health
echo "[1] Checking API health..."
curl -sk "$HOST/health" | jq .
echo
sleep 1

# 5) Simulate multiple payments with delays
echo "[2] Simulating payments..."
PAYMENTS=(50.00 75.00 120.50 250.00)
for amt in "${PAYMENTS[@]}"; do
    echo "Simulating payment: $amt"
    sudo -u psrm_admin bash -c "/opt/psrm/scripts/simulate_payment.sh $API_URL $amt"
    sleep 2
done
echo

# 6) Display the latest 5 payment log entries
echo "[3] Latest payment log entries:"
echo "--------------------------------------------------"
printf "%-25s %-15s %-10s\n" "Timestamp" "Transaction ID" "Status"
echo "--------------------------------------------------"
if [ -f "$LOG_FILE" ]; then
    sudo tail -n 5 "$LOG_FILE" | awk -F'\t' '{printf "%-25s %-15s %-10s\n", $1, $2, $3}'
else
    echo "[!] Payment log not found: $LOG_FILE"
fi
echo "--------------------------------------------------"
echo

echo "=== Demo Complete ==="
