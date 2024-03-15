#!/bin/bash

source .env

# Functions
# -----------------------------------------------------

usage() {
	echo "USAGE: ${BASH_SOURCE[0]} { start | stop | restart | prune }"

	exit 1
}

is-deployed() {
	[[ -e "$SHARED_DIR/var/lib/samba/private/secrets.keytab" ]] &&
		return 0 ||
		return 1
}

set-admin-pass() {
	# Prompt asking for a password
	read -s -r -p "Enter a (strong) admin password: " ADMIN_PASS
	echo ""
	read -s -r -p "Confirm the password: " ADMIN_PASS_CHECK
	echo ""

	[[ "$ADMIN_PASS" != "$ADMIN_PASS_CHECK" ]] && {
		echo "Passwords did not match!"
		exit 1
	}

	export ADMIN_PASS="$ADMIN_PASS"
}

start() {
	# Create the necessary shared folders
	mkdir -p "$BACKUP_DIR"
	mkdir -p "$SHARED_DIR/etc/samba"
	mkdir -p "$SHARED_DIR/var/lib/samba"
	mkdir -p "$SHARED_DIR/var/log/samba"

	! is-deployed && [[ -z $ADMIN_PASS ]] && set-admin-pass

	podman-compose --podman-run-args "-e ADMIN_PASS=$ADMIN_PASS --tty --interactive" up -d
	unset ADMIN_PASS
}

stop() {
	podman-compose down
}

prune() {
	stop
	podman image rm samba-ad-dc
	rm -rf "$SHARED_DIR"
}

# Execution
# -----------------------------------------------------

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
restart)
	stop
	sleep 1
	start
	;;
prune)
	prune
	;;
-h | --help)
	usage
	;;
*)
	usage
	;;
esac
