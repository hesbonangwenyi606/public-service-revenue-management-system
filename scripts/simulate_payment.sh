#!/usr/bin/env bash
# simulate_payment.sh
set -euo pipefail

# Default URL and amount
URL=${1:-http://127.0.0.1:5000/api/payments}
AMOUNT=${2:-100.50}

# Build JSON payload
PAYLOAD=$(cat <<JSON
{
  "payer_id": "TP-$(date +%s)",
  "amount": ${AMOUNT},
  "method": "card",
  "invoice": "INV-$(date +%Y%m%d%H%M%S)"
}
JSON
)

RESPONSE_FILE="/tmp/psrm_payment_response.json"

# Send POST request
curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$URL" -o "$RESPONSE_FILE"

# Parse response
if [[ -s "$RESPONSE_FILE" ]]; then
  python3 /opt/psrm/scripts/payment_parser.py "$RESPONSE_FILE"
  echo "Response saved to $RESPONSE_FILE"
else
  echo "No response or empty response from $URL"
fi
