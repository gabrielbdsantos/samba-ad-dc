#!/bin/bash

set -e

HERE=$(realpath -- $(dirname ${BASH_SOURCE[0]}))
PODMAN=$(which podman-compose)

usage() {
	echo "USAGE: ${BASH_SOURCE[0]} UNIT_NAME"
}

create-systemd-unit() {
	cat >"$1" <<EOF
[Unit]
Description=Containerized Samba AD DC
After=network.target

[Service]
Type=forking
WorkingDirectory=$HERE
ExecStart=$PODMAN up -d
ExecStop=$PODMAN down -v

[Install]
WantedBy=multi-user.target
EOF
}

if [[ -n "$1" ]]; then
	create-systemd-unit "$1"
else
	usage
fi
