#!/bin/bash

[ "$DEBUG" = "true" ] && set -x

PERSISTENT_STORAGE="/data/"
if [ -n "$LOCAL_INSTALL" ]; then
  PERSISTENT_STORAGE="/var/www/data/"
fi

  echo "######################################################"
  echo "##### Prestashop Clean ReInstall"
  echo "######################################################"

  echo "Drop DB Tables"
  mysql --silent --skip-column-names -h"$ARTIFAKT_MYSQL_HOST" -u"$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" -e "SHOW TABLES" "$ARTIFAKT_MYSQL_DATABASE_NAME" | xargs -L1 -I% echo 'SET FOREIGN_KEY_CHECKS=0;DROP TABLE `%`;SET FOREIGN_KEY_CHECKS=1;' | mysql -v -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" "$ARTIFAKT_MYSQL_DATABASE_NAME"

  if [ -n "$LOCAL_INSTALL" ]; then
    echo "Clean $PERSISTENT_STORAGE folder"
    rm -rf "$PERSISTENT_STORAGE*"
  fi