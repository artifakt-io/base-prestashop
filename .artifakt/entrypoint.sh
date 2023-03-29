#!/bin/bash
[ "$DEBUG" = "true" ] && set -x

APP_ROOT_PATH="/var/www/code";

echo "######################################################"
echo "##### DB connexion test"
while ! mysqladmin ping -h"$ARTIFAKT_MYSQL_HOST" --silent; do
    echo "Waiting for db..."
    sleep 1
done

if [ -z "$PRESTASHOP_CLEAN_REINSTALL" ]; then
    PRESTASHOP_CLEAN_REINSTALL=0
fi

if [ "$PRESTASHOP_CLEAN_REINSTALL" -eq 1 ] && [ "$ARTIFAKT_IS_MAIN_INSTANCE" -eq 1 ]; then
    sh /.artifakt/fresh_install.sh;
fi

echo "######################################################"
echo "##### Server Domain "
if [ -n "$PRESTASHOP_SERVER_DOMAIN" ]; then server_domain="$PRESTASHOP_SERVER_DOMAIN"; else server_domain="localhost"; fi
echo -e "Server domain is $server_domain\n"

configuration_table_name="configuration";
prefix="";
if [ -n "$ARTIFAKT_MYSQL_DATABASE_PREFIX" ]; then 
    echo "######################################################"
    echo "##### Table prefix && configuration table name"    
        configuration_table_name="$ARTIFAKT_MYSQL_DATABASE_PREFIX"_configuration;
        prefix=$ARTIFAKT_MYSQL_DATABASE_PREFIX"_";
    fi    
echo -e "Table prefix is $prefix\n"
echo -e "Configuration table name is $configuration_table_name\n"

if [ -z "$LOCAL_INSTALL" ];then
    echo "######################################################"
    echo "##### VARNISH && NGINX CONFIGURATION"
    echo "Varnish: Copy default.vcl in /conf/varnish mount folder."
    echo "nginx: Copy default.conf in /conf/nginx mount folder."
    echo "######################################################"

        cp -f /.artifakt/etc/varnish/default.vcl /conf/varnish/default.vcl || echo "No config default.vcl"
        cp -f /.artifakt/etc/nginx/default.conf /conf/nginxfpm/default.conf || echo "No config default.conf"
fi

if [ -n "$LOCAL_INSTALL" ]; then
    echo "######################################################"
    echo "Creation of default user prestashopuser in local mode"
    echo "######################################################"

        psUserCount=$(mysql -h "$ARTIFAKT_MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -B -N -e "SELECT COUNT(*) FROM mysql.user WHERE user = '$ARTIFAKT_MYSQL_USER';" | grep -v "count");
        if [ "$psUserCount" -eq 0 ]; then
            echo "### Prestashopuser creation:"
                mysql -h "$ARTIFAKT_MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD"  -e "CREATE USER '$ARTIFAKT_MYSQL_USER'@'%' IDENTIFIED BY '$ARTIFAKT_MYSQL_PASSWORD';"
                mysql -h "$ARTIFAKT_MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD"  -e "GRANT ALL ON $ARTIFAKT_MYSQL_DATABASE_NAME.* TO '$ARTIFAKT_MYSQL_USER'@'%';FLUSH PRIVILEGES;"
            echo "Local prestashopuser created."
        else
        echo "Local prestashopuser already exists."
    fi
else
    echo "No needs to create user."
fi

if [ ! -d "$APP_ROOT_PATH/$PRESTASHOP_ADMIN_PATH" ]; then
    echo "######################################################"
    echo "##### Prestashop import"
    echo "##### Prestashop version $PRESTASHOP_VERSION"
    echo "######################################################"
    echo "##### Prestashop import"

        cd /tmp && \
        wget https://download.prestashop.com/download/releases/prestashop_"$PRESTASHOP_VERSION".zip -q --show-progress && \
        unzip -qq prestashop_*.zip && \
        echo "### Unzip Prestashop zip in $APP_ROOT_PATH"
        unzip -qq prestashop.zip -d $APP_ROOT_PATH && \
        rm /tmp/*.zip  /tmp/index.php /tmp/Install_PrestaShop.html

    echo "######################################################"
    echo "##### PRESTASHOP PERMISSIONS"

        chown -R www-data:www-data $APP_ROOT_PATH/
        chmod -R 755 $APP_ROOT_PATH/   
else
    echo "Prestashop import is already done."
fi

if [ "$ARTIFAKT_IS_MAIN_INSTANCE" == 1 ]; then
    echo "### Check if the database is already installed"
    tableCount=$(mysql -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" "$ARTIFAKT_MYSQL_DATABASE_NAME" -B -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$ARTIFAKT_MYSQL_DATABASE_NAME';" | grep -v "count");
    echo "### Number of tables: $tableCount"

    if [ "$tableCount" -eq 0 ]; then

        if [ -d "$APP_ROOT_PATH/install" ]; then
            echo "######################################################"
            echo "##### PRESTASHOP CONFIGURATION"
            echo "######################################################"

                cd $APP_ROOT_PATH/install || exit
                su www-data -s /bin/bash -c "php index_cli.php --step=all --domain=$server_domain --db_server=$ARTIFAKT_MYSQL_HOST --db_name=$ARTIFAKT_MYSQL_DATABASE_NAME --db_user=$ARTIFAKT_MYSQL_USER --db_password=$ARTIFAKT_MYSQL_PASSWORD --language=fr --prefix=$prefix --name=$PRESTASHOP_PROJECT_NAME"  
            
            echo "######################################################"
            echo "### SSL DB OPERATIONS"
            echo "### Enable PS_SSL_ENABLED and PS_SSL_ENABLED_EVERYWHERE on main instance"

                if [  "$ARTIFAKT_IS_MAIN_INSTANCE" == 1 ]; then
                    configuration_table_name="$ARTIFAKT_MYSQL_DATABASE_PREFIX"_configuration;
                    mysql -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" "$ARTIFAKT_MYSQL_DATABASE_NAME" -e "UPDATE $configuration_table_name SET value = '1' WHERE name = 'PS_SSL_ENABLED';"
                    mysql -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" "$ARTIFAKT_MYSQL_DATABASE_NAME"  -e "UPDATE $configuration_table_name SET value = '1' WHERE name = 'PS_SSL_ENABLED_EVERYWHERE';"
                fi
        else 
            echo "Database is empty and there is no install folder. Please check."
        fi
    else
        echo -e "Database is not empty. Configuration is already done.\n"
    fi
    echo -e "Check domains.\n"
    shop_url_table_name="$ARTIFAKT_MYSQL_DATABASE_PREFIX"_shop_url;

    domain_check=$(mysql -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" "$ARTIFAKT_MYSQL_DATABASE_NAME" -B -N -e "SELECT domain FROM $shop_url_table_name;" | grep -v domain);
    if [ "$domain_check" != "$PRESTASHOP_SERVER_DOMAIN" ]; then
        mysql -h "$ARTIFAKT_MYSQL_HOST" -u "$ARTIFAKT_MYSQL_USER" -p"$ARTIFAKT_MYSQL_PASSWORD" "$ARTIFAKT_MYSQL_DATABASE_NAME" -e "UPDATE $shop_url_table_name SET domain=\"$PRESTASHOP_SERVER_DOMAIN\", domain_ssl=\"$PRESTASHOP_SERVER_DOMAIN\" WHERE main = '1';"
        echo -e "Domains are set."
    else
        echo -e "Domains already set."
    fi    
fi

if [ -d "$APP_ROOT_PATH/admin" ]; then
    echo "###############################################################"
    echo "##### ADMIN FOLDER NAME CHANGE: admin to $PRESTASHOP_ADMIN_PATH"
        # cd $APP_ROOT_PATH || exit
        mv admin back_admin
        rm -rf admin*
        mv back_admin "$PRESTASHOP_ADMIN_PATH"
    else
        mv "$PRESTASHOP_ADMIN_PATH" back_admin
        rm -rf admin*
        mv back_admin "$PRESTASHOP_ADMIN_PATH"
fi
 
echo "###############################################################"
echo "##### Cache clear"

su www-data -s /bin/bash -c "bin/console cache:clear"
echo -e "##### Cache clear\n"
echo "###############################################################"

# if [ -d "$APP_ROOT_PATH/install/" ]; then
#     echo "### Remove install folder"
#     rm -rf $APP_ROOT_PATH/install || true
# fi

echo "##### End of entrypoint.sh execution"


if [ -n "$LOCAL_INSTALL" ]; then
    echo "###############################################################"
    echo "##### Summary"
    echo "###############################################################"
    echo "##### Server name: $server_domain"
    echo "##### Backoffice password: 0123456789"
    echo "##### Site url: https://$server_domain"
    echo "##### Backoffice url: https://$server_domain/$PRESTASHOP_ADMIN_PATH"
    echo "##### Email to connect: pub@prestashop.com"
    echo "##### Connect to the database from app container: mysql -u \$ARTIFAKT_MYSQL_USER -h \$ARTIFAKT_MYSQL_HOST -p\$ARTIFAKT_MYSQL_PASSWORD \$ARTIFAKT_MYSQL_DATABASE_NAME;"
    echo "##### Get native env variables from .env in local or console in Artifakt environment in app container : Just type 'env'"
fi
