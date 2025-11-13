#!/usr/bin/env bash
# gen_selfsigned_cert.sh
CERT_DIR=/etc/ssl/psrm
mkdir -p ${CERT_DIR}
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ${CERT_DIR}/psrm.key \
  -out ${CERT_DIR}/psrm.crt \
  -subj "/C=KE/ST=Nairobi/L=Nairobi/O=PSRM/OU=IT/CN=psrm.local"
echo "Self-signed cert created at ${CERT_DIR}"