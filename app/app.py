#!/usr/bin/env python3
import sys
import json

# ANSI color codes
COLORS = {
    "COMPLETED": "\033[92m",  # Green
    "FAILED": "\033[91m",     # Red
    "PENDING": "\033[93m",    # Yellow
    "RESET": "\033[0m"
}

if len(sys.argv) != 2:
    print("Usage: payment_parser.py <response_json_file>")
    sys.exit(1)

file_path = sys.argv[1]

try:
    with open(file_path, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"Error reading {file_path}: {e}")
    sys.exit(1)

timestamp = data.get("timestamp", "N/A")
tx_id = data.get("transaction_id", "N/A")
status = data.get("status", "N/A")

color = COLORS.get(status.upper(), COLORS["RESET"])
print(f"{timestamp:<30} {tx_id:<20} {color}{status:<10}{COLORS['RESET']}")

# Append to log
log_file = "/opt/psrm/logs/payment_status.log"
with open(log_file, "a") as log:
    log.write(f"{timestamp:<30} {tx_id:<20} {status}\n")
