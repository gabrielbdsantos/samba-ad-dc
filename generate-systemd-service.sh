#!/bin/bash

set -e

HERE=$(realpath -- $(dirname ${BASH_SOURCE[0]}))
PODMAN=$(which podman-compose)

cat >"$1" <<EOF
[Unit]
Description=Containerized Samba AD DC
After=network.target

[Service]
Restart=always
WorkingDirectory=$HERE
ExecStart=$PODMAN up -d
ExecStop=$PODMAN down -v

[Install]
WantedBy=multi-user.target
EOF
