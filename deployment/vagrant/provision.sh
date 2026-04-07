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
sudo apt update && apt upgrade

# install apache2
sudo apt-get install -y apache2

# install nginx
# sudo apt-get install -y nginx

# install php modules
sudo add-apt-repository ppa:ondrej/php # Press enter when prompted.
sudo apt update
sudo apt-get install -y php8.2
sudo apt-get install -y php8.2-cli
sudo apt-get install -y php8.2-bz2
sudo apt-get install -y php8.2-curl
sudo apt-get install -y php8.2-mbstring
sudo apt-get install -y php8.2-intl
sudo apt-get install -y php8.2-fpm
sudo apt-get install -y php8.2-xml
sudo apt-get install -y zip
sudo apt-get install -y unzip
sudo apt-get install -y php8.2-zip 
sudo apt-get install -y php8.2-mysql 

sudo apt-get install php-xdebug
# echo "zend_extension=xdebug.so" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.mode=debug" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.client_host=192.168.30.4" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.client_port=9003" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.connect_timeout_ms=1" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.start_with_request=yes" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.discover_client_host=1" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.max_stack_frames=5" | sudo tee -a /etc/php/8.2/cli/php.ini
# echo "xdebug.log_level=0" | sudo tee -a /etc/php/8.2/cli/php.ini

sudo systemctl restart apache2 
sudo apt-get install curl
sudo apt-get install php php-curl
sudo apt install nodejs -y
sudo apt install npm -y yes ''
sudo apt install awscli -y

sudo ${DEPLOY_FILES}/expenses-apache.sh ${HOST_OS} ${USERNAME} ${DEPLOY_FILES} ${APP_IP_EXPENSE} ${DOMAIN_NAME}

sudo curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

git config --global --add safe.directory /var/www/html/slayd/current
cd /var/www/html/slayd/current/expense
composer update
composer i
npm init
npm i

sudo a2enmod rewrite
sudo usermod -a -G www-data vagrant
# sudo chown -R vagrant:vagrant /var/www/html/slayd/current/expense
sudo chmod -R 777 /var/www/html/slayd/current/expense/var/
sudo chown -R www-data:www-data /var/www/html/slayd/current/expense/var/
sudo systemctl restart apache2
php bin/console cache:clear
php bin/console asset-map:compile
sudo rm -rf /var/www/html/slayd/current/expense/var/cache/
php bin/console cache:clear
php bin/console tailwind:init
php bin/console tailwind:build