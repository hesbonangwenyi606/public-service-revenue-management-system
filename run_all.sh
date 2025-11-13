#!/usr/bin/env bash
# run_all.sh - automates PSRM demo setup steps (AlmaLinux 9.6)
# Usage: sudo ./run_all.sh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PSRM_USER="psrm_admin"
PSRM_DIR="/opt/psrm"
SUDO_CMD="sudo"

echo "== PSRM quick installer =="
echo "Project dir: $PROJECT_DIR"

# 1) Create user if missing
if id -u "$PSRM_USER" >/dev/null 2>&1; then
  echo "User $PSRM_USER already exists."
else
  echo "Creating user $PSRM_USER..."
  $SUDO_CMD useradd -m -s /bin/bash "$PSRM_USER"
fi

# 2) Create target directories
echo "Creating directories under $PSRM_DIR ..."
$SUDO_CMD mkdir -p "$PSRM_DIR"/{logs,backups,app}
$SUDO_CMD chown -R "$PSRM_USER":"$PSRM_USER" "$PSRM_DIR"
$SUDO_CMD chmod 700 "$PSRM_DIR" "$PSRM_DIR"/logs "$PSRM_DIR"/backups

# 3) Copy app folder into /opt/psrm/app if not already present
if [ -d "$PSRM_DIR/app" ] && [ "$(ls -A "$PSRM_DIR/app")" ]; then
  echo "/opt/psrm/app already has content — skipping copy."
else
  echo "Copying app/ to $PSRM_DIR/app ..."
  $SUDO_CMD cp -r "$PROJECT_DIR"/app/* "$PSRM_DIR/app/"
  $SUDO_CMD chown -R "$PSRM_USER":"$PSRM_USER" "$PSRM_DIR/app"
fi

# 4) Make scripts executable
echo "Making scripts executable..."
find "$PROJECT_DIR"/scripts -type f -iname "*.sh" -exec $SUDO_CMD chmod +x {} \;
find "$PROJECT_DIR"/scripts -type f -iname "*.py" -exec $SUDO_CMD chmod +x {} \;

# 5) Python venv and dependencies (inside /opt/psrm/app)
echo "Setting up Python venv and installing dependencies..."
APP_PATH="$PSRM_DIR/app"
PYTHON_BIN=$(command -v python3 || true)
if [ -z "$PYTHON_BIN" ]; then
  echo "Python3 not found. Install Python3 (python3) and re-run script."
  exit 1
fi

# run venv creation as the psrm user to avoid root-owned venv problems
$SUDO_CMD -u "$PSRM_USER" bash -c "cd '$APP_PATH' && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip >/dev/null && pip install -r requirements.txt >/dev/null"

echo "Python environment ready at $APP_PATH/venv"

# 6) Start the Flask app with nohup+gunicorn (simple demo, not production systemd)
echo "Starting Flask app using gunicorn (background)..."
$SUDO_CMD -u "$PSRM_USER" bash -c "cd '$APP_PATH' && source venv/bin/activate && nohup gunicorn -w 2 -b 127.0.0.1:5000 app:app >/tmp/psrm_gunicorn.out 2>&1 & echo \$! > /tmp/psrm_gunicorn.pid"
echo "Gunicorn started, pid file: /tmp/psrm_gunicorn.pid"

# 7) Generate self-signed cert and install nginx config
echo "Generating self-signed certificate and installing nginx config..."
if ! command -v nginx >/dev/null 2>&1; then
  echo "nginx not found. Installing nginx..."
  $SUDO_CMD dnf install -y nginx
fi

$SUDO_CMD bash -c "'$PROJECT_DIR'/scripts/gen_selfsigned_cert.sh"
$SUDO_CMD cp "$PROJECT_DIR"/app/nginx.conf /etc/nginx/conf.d/psrm.conf
$SUDO_CMD systemctl enable --now nginx

# 8) Firewall rules (firewalld)
if command -v firewall-cmd >/dev/null 2>&1; then
  echo "Allowing ssh, http, https through firewall..."
  $SUDO_CMD firewall-cmd --permanent --add-service=ssh
  $SUDO_CMD firewall-cmd --permanent --add-service=http
  $SUDO_CMD firewall-cmd --permanent --add-service=https
  $SUDO_CMD firewall-cmd --reload
else
  echo "firewalld not present or firewall-cmd not found — skipping firewall modification."
fi

# 9) Install cron job (oracle watcher)
echo "Installing cron file to /etc/cron.d/psrm_oracle_watch ..."
if [ -f "$PROJECT_DIR/cron/psrm_oracle_watch.cron" ]; then
  $SUDO_CMD cp "$PROJECT_DIR/cron/psrm_oracle_watch.cron" /etc/cron.d/psrm_oracle_watch
  $SUDO_CMD chmod 644 /etc/cron.d/psrm_oracle_watch
  $SUDO_CMD systemctl restart crond || true
else
  echo "Cron file missing in project/cron. Skipping."
fi

# 10) Copy scripts into /opt/psrm/scripts for easier access
echo "Copying helper scripts to $PSRM_DIR/scripts ..."
$SUDO_CMD mkdir -p "$PSRM_DIR/scripts"
$SUDO_CMD cp -r "$PROJECT_DIR"/scripts/* "$PSRM_DIR/scripts/"
$SUDO_CMD chown -R "$PSRM_USER":"$PSRM_USER" "$PSRM_DIR/scripts"
$SUDO_CMD chmod +x "$PSRM_DIR/scripts"/*

echo
echo "=== QUICK MANUAL STEPS YOU MUST DO (ORACLE + SQL) ==="
echo "1) Install/configure Oracle Database (or Oracle XE) on this host and ensure sqlplus/expdp are available."
echo "2) Run the SQL scripts to create tables and insert sample data:"
echo "   sqlplus PSRM_DB/password@ORCL @${PROJECT_DIR}/sql/create_tables.sql"
echo "   sqlplus PSRM_DB/password@ORCL @${PROJECT_DIR}/sql/sample_data.sql"
echo
echo "=== QUICK TESTS ==="
echo "1) API health check:"
echo "   curl -s http://127.0.0.1:5000/health | jq ."
echo "2) Simulate a payment (this will call the local Flask API):"
echo "   sudo -u $PSRM_USER bash -c '$PSRM_DIR/scripts/simulate_payment.sh http://127.0.0.1:5000/api/payments 123.45'"
echo "3) View payment status log:"
echo "   sudo cat $PSRM_DIR/logs/payment_status.log"
echo
echo "If you need the Flask app exposed via HTTPS for 'psrm.local', add to /etc/hosts:"
echo "  127.0.0.1 psrm.local"
echo "Then test: curl -k https://psrm.local/health"
echo
echo "Run complete. If any command failed, inspect output above. Logs: /tmp/psrm_gunicorn.out, /tmp/psrm_gunicorn.pid"
