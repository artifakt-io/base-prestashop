#!/bin/sh
[ "$DEBUG" = "true" ] && set -x

echo "BUILD.SH";

sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
apt-get update && \
apt-get -y upgrade && \
apt-get install -y \
byobu \
curl \
git \
htop \
libfcgi-bin \
man \
mariadb-client \
rsync \
unzip \
vim \
wget \
&& rm -rf /var/lib/apt/lists/*


echo "######################################################"
echo "##### Admin path in varnish and nginx conf "
sed -i "s/ADMIN_TO_CHANGE/$PRESTASHOP_ADMIN_PATH/g" /.artifakt/etc/varnish/default.vcl
sed -i "s/ADMIN_TO_CHANGE/$PRESTASHOP_ADMIN_PATH/g" /.artifakt/etc/nginx/default.conf



