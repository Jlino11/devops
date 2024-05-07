#!/bin/bash

LINK="https://github.com/roxsross/The-DevOps-Journey-101.git"

# Updates repos
sudo apt-get update

# Installing MariaDB

sudo apt install -y mariadb-server
sudp systemctl start mariadb
sudo sustemctl enable mariadb

# Config DB

# Install required packages

sudo apt install -y apache2\
	php libapache2-mod-php\
	php-mysql

# Enable web service

sudo systemctl start apache2
sudo systemctl enable apache2


# Installing SCM

sudo apt install -y git


# Cloning repo

git clone $LINK
cp -r The-DevOps-Journey-101/CLASE-02/lamp-app-ecommerce/* /var/www/html/
mv /var/www/html/index.html /var/www/html/index.html.bkp


