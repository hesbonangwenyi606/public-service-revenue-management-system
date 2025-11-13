#!/bin/bash

# Array of payment amounts to simulate
payments=(50.00 75.00 120.50 250.00)

# Loop through each payment
for amount in "${payments[@]}"; do
    echo "Simulating payment: $amount"

    # --- Simulate the payment (your existing code) ---
    echo "[✓] Payment completed!"

    # --- Log the payment ---
    timestamp=$(date -Iseconds)
    transaction_id="TX-$(openssl rand -hex 6)"
    status="COMPLETED"
    sudo bash -c "echo \"$timestamp      $transaction_id $status\" >> /opt/psrm/logs/payment_status.log"
done

# --- Show the latest 10 log entries ---
echo
echo "[3] Latest payment log entries:"
echo "--------------------------------------------------"
echo "Timestamp                 Transaction ID  Status"
echo "--------------------------------------------------"
sudo tail -n 10 /opt/psrm/logs/payment_status.log
echo "--------------------------------------------------"
