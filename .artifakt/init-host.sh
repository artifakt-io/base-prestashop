#!/bin/bash
[ "$DEBUG" = "true" ] && set -x

cp -f /var/lib/docker/volumes/services_nginxfpm-conf/_data/default.conf /etc/nginx/conf.d/default.conf  || echo "No config default.conf"