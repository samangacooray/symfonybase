#!/usr/bin/env bash

HOST_OS=$1
ENV_NAME=$2
DOMAIN_NAME=$3
HOSTNAME=$4
APP_IP_EXPENSE=$5
SERVICES_IP=$6
USERNAME=$7
DEPLOY_FILES=$8
GUEST_UID=$9
GUEST_GID=$10

sudo ${DEPLOY_FILES}/group.sh
sudo ${DEPLOY_FILES}/host.sh local ${DOMAIN_NAME} ${SERVICES_IP} ${APP_IP_EXPENSE}
sudo apt update && sudo apt upgrade -y

# Install Apache
sudo apt-get install -y apache2

# Install PHP (latest from ondrej/php)
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
PHP_VER=$(apt-cache search --names-only '^php[0-9]+\.[0-9]+-cli$' | awk -F'-' '{print $1}' | sort -V | tail -1 | sed 's/php//')
sudo apt-get install -y php${PHP_VER} php${PHP_VER}-cli php${PHP_VER}-bz2 php${PHP_VER}-curl \
  php${PHP_VER}-mbstring php${PHP_VER}-intl php${PHP_VER}-fpm php${PHP_VER}-xml \
  php${PHP_VER}-zip php${PHP_VER}-mysql zip unzip

sudo apt-get install -y php-xdebug

# Install Node.js LTS via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Angular CLI globally
sudo npm install -g @angular/cli@19

sudo apt-get install -y curl awscli

# Configure and restart Apache
sudo ${DEPLOY_FILES}/expenses-apache.sh ${HOST_OS} ${USERNAME} ${DEPLOY_FILES} ${APP_IP_EXPENSE} ${DOMAIN_NAME}

# Install Composer
sudo curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

# Symfony API setup
git config --global --add safe.directory /var/www/html/slayd/current
cd /var/www/html/slayd/current/expense
composer install

sudo chmod -R 777 /var/www/html/slayd/current/expense/var/
sudo chown -R ${USERNAME}:${USERNAME} /var/www/html/slayd/current/expense/var/
php bin/console cache:clear

# Angular SPA setup
cd /var/www/html/slayd/current/expense-spa
npm install
npm run build:prod

sudo a2enmod rewrite
sudo usermod -a -G www-data ${USERNAME}
sudo systemctl restart apache2
