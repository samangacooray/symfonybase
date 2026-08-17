#!/usr/bin/env bash

HOST_OS=$1
USERNAME=$2
DEPLOY_FILES=$3
APACHE_EXPENSE_WEB_IP=$4
APACHE_EXPENSE_WEB_DOMAIN=$5

sed -e "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=${USERNAME}/g" -i /etc/apache2/envvars
sed -e "s/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=users/g" -i /etc/apache2/envvars

# Add port 8080 for Symfony if not already present
grep -q "^Listen 8080" /etc/apache2/ports.conf || echo "Listen 8080" >> /etc/apache2/ports.conf

sudo cp ${DEPLOY_FILES}/expenses-apache.conf /etc/apache2/sites-available/expenses.conf
sudo a2dissite 000-default.conf
sudo a2ensite expenses.conf
sudo a2enmod rewrite proxy proxy_http
sudo systemctl restart apache2
