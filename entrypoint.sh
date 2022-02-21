#!/bin/sh
set -e

iptables -t nat -A POSTROUTING -s "0/0" -j MASQUERADE

exec "$@"
