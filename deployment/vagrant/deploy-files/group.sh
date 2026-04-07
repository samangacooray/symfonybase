#!/usr/bin/env bash

# Allow sshd to auth when the home dir has g+rw.
sed -i.org -e "s/StrictModes yes/StrictModes no/" /etc/ssh/sshd_config
