#!/bin/bash

PERSISTENT_STORAGE="/data/"

if [ -n "$LOCAL_INSTALL" ]; then
    PERSISTENT_STORAGE="/var/www/data/"
fi

echo "$APP_ROOT_PATH_DEFINED";
echo "Drop DB Tables"
    mysql --silent --skip-column-names -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" -e "SHOW TABLES" "$ARTIFAKT_MYSQL_DATABASE_NAME" | xargs -L1 -I% echo 'DROP TABLE `%`;' | mysql -v -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" "$ARTIFAKT_MYSQL_DATABASE_NAME"
echo "Clean $APP_ROOT_PATH_DEFINED folder"
    rm -rf "${APP_ROOT_PATH_DEFINED:?}/"*
echo "Clean $PERSISTENT_STORAGE folder"
    rm -rf $PERSISTENT_STORAGE*
echo "Done"

