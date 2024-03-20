#!/usr/bin/env bash

set -e
set -o pipefail
set -x

SAMBA_PATH=${SAMBA_PATH:-/var/lib/samba}

# Skip domain provision if secrets.keytab already exists
if [[ ! -e "$SAMBA_PATH/private/secrets.keytab" ]]; then
	samba-tool domain provision \
		--use-rfc2307 \
		--server-role="${SERVER_ROLE:-dc}" \
		--dns-backend="${DNS_BACKEND:-SAMBA_INTERNAL}" \
		--realm="${REALM}" \
		--domain="${DOMAIN}" \
		--adminpass="${ADMIN_PASS}" \
		--option="dns forwarder = ${DNS_FORWARD}" \
		--options="interfaces = ${LISTEN_INTERFACES}" \
		--options="bind interfaces only = yes"
fi

# Link the necessary kerberos configuration file
ln -sf "$SAMBA_PATH/private/krb5.conf" /etc

samba --foreground --no-process-group
