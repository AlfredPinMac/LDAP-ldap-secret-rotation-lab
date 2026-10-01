#!/bin/sh
set -eu

LDAP_HOST="${LDAP_HOST:-openldap}"
LDAP_PORT="${LDAP_PORT:-389}"
LDAP_BASE_DN="${LDAP_BASE_DN:-dc=example,dc=com}"
LDAP_ADMIN_DN="cn=admin,${LDAP_BASE_DN}"
SECRETS_FILE="/secrets/ldap_secret.env"

# Determine current admin password
CURRENT_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD:-adminpassword}"
if [ -f "${SECRETS_FILE}" ]; then
  CURRENT_ADMIN_PASSWORD=$(grep -E '^(export )?LDAP_ADMIN_PASSWORD=' "${SECRETS_FILE}" | head -n1 | cut -d'=' -f2 | tr -d '"'\'' ')
fi

echo "============================================================"
echo "[LDAP BOOTSTRAP] Initializing OpenLDAP Seed Data..."
echo "[LDAP BOOTSTRAP] Host: ${LDAP_HOST}:${LDAP_PORT}"
echo "============================================================"

# Wait for OpenLDAP to be responsive
until ldapsearch -x -H "ldap://${LDAP_HOST}:${LDAP_PORT}" -b "${LDAP_BASE_DN}" -s base >/dev/null 2>&1; do
  echo "[LDAP BOOTSTRAP] Waiting for OpenLDAP server to become ready..."
  sleep 2
done

# Initialize shared ldap secrets file if not present
mkdir -p /secrets
if [ ! -f "${SECRETS_FILE}" ]; then
  cat <<EOF > "${SECRETS_FILE}"
export LDAP_ADMIN_PASSWORD="${CURRENT_ADMIN_PASSWORD}"
EOF
fi

# Check if users already exist
if ldapsearch -x -H "ldap://${LDAP_HOST}:${LDAP_PORT}" -D "${LDAP_ADMIN_DN}" -w "${CURRENT_ADMIN_PASSWORD}" -b "ou=users,${LDAP_BASE_DN}" >/dev/null 2>&1; then
  echo "[LDAP BOOTSTRAP] Directory entries already initialized."
else
  echo "[LDAP BOOTSTRAP] Importing users.ldif into directory..."
  ldapadd -x -H "ldap://${LDAP_HOST}:${LDAP_PORT}" \
    -D "${LDAP_ADMIN_DN}" \
    -w "${CURRENT_ADMIN_PASSWORD}" \
    -f /LDAP/users.ldif || true
  echo "[LDAP BOOTSTRAP] LDIF successfully loaded!"
fi

echo "[LDAP BOOTSTRAP] OpenLDAP ready for authentication."
