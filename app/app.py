# Simple Flask app to simulate PSRM payment API
from flask import Flask, request, jsonify
import uuid, random, datetime
app = Flask(__name__)

@app.route('/api/payments', methods=['POST'])
def payments():
    data = request.get_json(force=True)
    transaction_id = 'TX-' + uuid.uuid4().hex[:12]
    status = random.choice(['SUCCESS', 'FAILED', 'PENDING'])
    # In a real app we'd persist to DB. Here we just return a JSON response.
    resp = {
        "transaction_id": transaction_id,
        "status": status,
        "amount": data.get('amount'),
        "timestamp": datetime.datetime.utcnow().isoformat() + 'Z'
    }
    return jsonify(resp), 200

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status":"ok","service":"psrm-flask","time": datetime.datetime.utcnow().isoformat() }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)