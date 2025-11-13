#!/usr/bin/env python3
"""Parses payment API JSON response and appends transaction ID and status to log."""
import sys, json, os
LOG='/opt/psrm/logs/payment_status.log'
def main(path):
    try:
        with open(path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f'Failed to load JSON: {e}')
        return
    tid = data.get('transaction_id') or data.get('tx_id') or data.get('id') or 'unknown'
    status = data.get('status') or data.get('result') or 'unknown'
    line = f"{__import__('datetime').datetime.utcnow().isoformat()}\t{tid}\t{status}\n"
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    with open(LOG, 'a') as f:
        f.write(line)
    print(f'Appended to {LOG}: {line.strip()}')
if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: payment_parser.py <response_json_file>')
    else:
        main(sys.argv[1])