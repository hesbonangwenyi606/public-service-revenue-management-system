#!/bin/bash

# Array of payment amounts to simulate
payments=(50.00 75.00 120.50 250.00)

# Possible payment statuses
statuses=("COMPLETED" "FAILED" "PENDING")

# Loop through each payment
for amount in "${payments[@]}"; do
    echo "Simulating payment: $amount"

    # Randomly pick a status
    status=${statuses[$RANDOM % ${#statuses[@]}]}

    # Show completion message based on status
    if [ "$status" = "COMPLETED" ]; then
        echo "[✓] Payment completed!"
    elif [ "$status" = "FAILED" ]; then
        echo "[✗] Payment failed!"
    else
        echo "[~] Payment pending..."
    fi

    # --- Log the payment with milliseconds ---
    timestamp=$(date +"%Y-%m-%dT%H:%M:%S.%6N")
    transaction_id="TX-$(openssl rand -hex 6)"
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
