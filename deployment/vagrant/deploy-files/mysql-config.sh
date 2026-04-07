#!/usr/bin/env bash

DEPLOY_FILES_DIR=$1
GUEST_HOME_DIR=$2
MYSQL_USERNAME=$3
MYSQL_PASSWORD=$4

sed -e "s/\${MYSQL_USERNAME}/${MYSQL_USERNAME}/g" -e "s/\${MYSQL_PASSWORD}/${MYSQL_PASSWORD}/g" $DEPLOY_FILES_DIR/my.cnf > ${GUEST_HOME_DIR}/.my.cnf
chown vagrant:vagrant ${GUEST_HOME_DIR}/.my.cnf

# Can delete when next time build local box. 1.0.2 above
# grep -qxF 'default-time-zone = "UTC"' /etc/mysql/my.cnf || echo $'\n''default-time-zone = "UTC"' | sudo tee -a /etc/mysql/my.cnf
sudo service mysql restart


