#!/usr/bin/env bash

DEPLOY_FILES_DIR=$1
MYSQL_USERNAME=$2
MYSQL_PASSWORD=$3
DATABASE_NAME=$4

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt -yq install mysql-server 
sudo apt -yq install mysql-client
sudo apt -yq install bzip2

cat $DEPLOY_FILES_DIR/my.cnf >> /etc/mysql/my.cnf
# sudo service mysql restart;
sudo mysql -u root;
mysql -e "CREATE USER 'awsmysql'@'mysql.expenses.com' IDENTIFIED WITH mysql_native_password BY 'samanga';";
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'awsmysql'@'mysql.expenses.com' WITH GRANT OPTION;";
mysql -e "FLUSH PRIVILEGES;";
mysql -e "system mysql --user=awsmysql --password=samanga --host=mysql.expenses.com;";
mysql -e "create database if not exists ${DATABASE_NAME}";
mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;";
# mysql -e "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u awsmysql samanga;"
sudo service mysql restart;