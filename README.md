# Public Service Revenue Management (PSRM) - Candidate Project
**Deliverable:** Full working project archive for the PSRM Linux/Oracle environment.

## Structure
- scripts/
  - backup_db.sh               -> Backup Oracle schema (timestamped)
  - check_oracle.sh            -> Cron-run checker to restart Oracle if down
  - list_oracle_processes.sh   -> Lists Oracle-related processes & top memory consumers
  - simulate_payment.sh        -> Uses curl to POST a payment to the Flask app
  - gen_selfsigned_cert.sh     -> Generate self-signed cert for NGINX
- sql/
  - create_tables.sql          -> CREATE TABLE statements for Oracle (SQL*Plus)
  - sample_data.sql            -> INSERT sample data
- app/
  - app.py                     -> Simple Flask app (payments API)
  - requirements.txt
  - wsgi.py
  - nginx.conf                 -> NGINX reverse-proxy config (snippet)
- cron/
  - psrm_oracle_watch.cron     -> Cron entry (run every 5 minutes)
- docs/
  - system_setup.md            -> Steps to run and test the project, explanations, challenges
- logs/ (example placeholder files)
  - backup.log
  - payment_status.log
- psrm_project.zip             -> This archive (created for download)

## Notes / Assumptions
- This package is an offline deliverable: it contains scripts, configs, and a Flask app.
- Oracle-specific commands (expdp/exp, sqlplus) require a working Oracle client and proper environment variables (ORACLE_HOME, ORACLE_SID, PATH).
- Adjust database credentials and directory names inside scripts to match your environment.
- The Flask app listens on port 5000 by default and demonstrates API flow for Task 3.
- NGINX config uses a self-signed certificate; the included script helps create it.

## How to use (high level)
1. Extract zip to a chosen location (or copy scripts to target server).
2. Run `chmod +x scripts/*.sh` to make scripts executable.
3. Create the psrm_admin user and directories:
   ```
   sudo useradd -m -s /bin/bash psrm_admin
   sudo mkdir -p /opt/psrm/{logs,backups,app}
   sudo chown -R psrm_admin:psrm_admin /opt/psrm
   sudo chmod 700 /opt/psrm /opt/psrm/logs /opt/psrm/backups
   ```
4. Install Python dependencies and run the Flask app:
   ```
   python3 -m venv venv
   source venv/bin/activate
   pip install -r app/requirements.txt
   python app/app.py
   ```
5. Test payment simulation:
   ```
   scripts/simulate_payment.sh
   ```
6. Set up NGINX with `app/nginx.conf`, generate self-signed cert using `scripts/gen_selfsigned_cert.sh`, enable the site, and restart nginx.
7. Install cron job using `crontab -e` and add contents of cron/psrm_oracle_watch.cron (or copy to /etc/cron.d/psrm_oracle_watch).

Full details and troubleshooting are in docs/system_setup.md.# public-service-revenue-management-system
