#!/bin/bash

# Parameters
# -----------------------------------------------------

HERE=$(realpath -- $(dirname "${BASH_SOURCE[0]}"))

SHARED_FOLDER=${SHARED_FOLDER:-$HERE/shared}
SAMBA_PATH=$SHARED_FOLDER/var/lib/samba

# Functions
# -----------------------------------------------------

usage() {
	echo "USAGE: run.sh { start | stop | restart }"

	exit 1
}

is-deployed() {
	[[ -e "$SAMBA_PATH/private/secrets.keytab" ]] &&
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
	mkdir -p "$SHARED_FOLDER/backup"
	mkdir -p "$SHARED_FOLDER/etc/samba"
	mkdir -p "$SHARED_FOLDER/var/lib/samba"
	mkdir -p "$SHARED_FOLDER/var/log/samba"

	! is-deployed && [[ -z $ADMIN_PASS ]] && set-admin-pass
	# ! is-deployed && [[ -z $ADMIN_PASS ]] && {
	# 	echo "Please, specify the ADMIN_PASS environment variable"
	# 	exit 1
	# }

	podman-compose --podman-run-args "-e ADMIN_PASS=$ADMIN_PASS --tty --interactive" up -d
	unset ADMIN_PASS
}

stop() {
	podman-compose down
}

prune() {
	stop
	podman image rm samba-ad-dc
	rm -rf "$SHARED_FOLDER"
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
*)
	usage
	;;
esac
