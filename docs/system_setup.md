# System Setup Steps, Testing Approach, and Challenges

## System Setup Steps (detailed)
1. Create user and directories:
   ```
   sudo useradd -m -s /bin/bash psrm_admin
   sudo mkdir -p /opt/psrm/{logs,backups,app}
   sudo chown -R psrm_admin:psrm_admin /opt/psrm
   sudo chmod 700 /opt/psrm /opt/psrm/logs /opt/psrm/backups
   ```
2. Make scripts executable:
   ```
   sudo chmod +x /opt/psrm/scripts/*.sh
   sudo chmod +x /opt/psrm/scripts/*.py
   ```
3. Oracle DB:
   - Ensure Oracle Database or Oracle XE is installed and running.
   - Configure DIRECTORY objects if using expdp.
   - Use `sqlplus` or SQL Developer to run `sql/create_tables.sql` and `sql/sample_data.sql`.
   - Example:
     ```
     sqlplus PSRM_DB/password@ORCL @sql/create_tables.sql
     sqlplus PSRM_DB/password@ORCL @sql/sample_data.sql
     ```
4. Running Flask app:
   ```
   python3 -m venv venv
   source venv/bin/activate
   pip install -r app/requirements.txt
   python3 app/app.py
   ```
   Or run with gunicorn:
   ```
   gunicorn -w 3 -b 127.0.0.1:5000 app:app
   ```
5. NGINX:
   - Copy `app/nginx.conf` to `/etc/nginx/conf.d/psrm.conf` (or sites-available/site-enabled).
   - Generate certs with `/opt/psrm/scripts/gen_selfsigned_cert.sh` (requires sudo).
   - Restart nginx: `sudo systemctl restart nginx`
6. Firewall:
   ```
   sudo firewall-cmd --permanent --add-service=ssh
   sudo firewall-cmd --permanent --add-service=http
   sudo firewall-cmd --permanent --add-service=https
   sudo firewall-cmd --reload
   ```
7. Cron:
   - Add the cron entry from `cron/psrm_oracle_watch.cron` to `/etc/cron.d/psrm_oracle_watch` or crontab.

## Testing Approach
- Task 1: Create directories & user and run permission checks (`ls -ld /opt/psrm*`, `id psrm_admin`).
- Task 2: Execute SQL scripts in a controlled environment (SQL*Plus) and run `SELECT COUNT(*) FROM TAXPAYERS;` etc.
- Task 3: Start the Flask app and run `scripts/simulate_payment.sh`. Inspect `/opt/psrm/logs/payment_status.log`.
- Task 4: Run `scripts/list_oracle_processes.sh` and configure cron; check `/opt/psrm/logs/oracle_watch.log` after some minutes.
- Task 5: Configure nginx, visit `https://psrm.local` (add `127.0.0.1 psrm.local` to /etc/hosts), and verify via browser or `curl -k https://psrm.local/health`.

## Challenges & Notes
- Oracle tooling (expdp/exp/sqlplus) requires an installed Oracle client and environment variables; the backup script includes fallbacks but a production setup should use Data Pump (expdp).
- Running system-level actions (systemctl restart oracle) may require root privileges—cron entries in /etc/cron.d or root crontab are recommended.
- SSL: self-signed certs will produce browser warnings; for production use obtain CA-signed certificates.
- Paths and usernames should be adapted to your environment. Test carefully in a non-production environment first.