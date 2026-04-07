#!/usr/bin/env bash

LOCAL=$1
DOMAIN_NAME=$2
SERVICES_IP=$3
APP_IP_EXPENSE=$4

if [ `grep -c "mysql." /etc/hosts` -eq 0 ]; then
    echo "${SERVICES_IP} mysql.${DOMAIN_NAME}" >> /etc/hosts
fi

if [ `grep -c "dev." /etc/hosts` -eq 0 ]; then
    echo "${APP_IP_EXPENSE} dev.${DOMAIN_NAME}" >> /etc/hosts
fi