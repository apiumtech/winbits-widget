#!/usr/bin/env bash

set -e
set -x

#DOWNLOAD PACKAGES
cd widget && rm npm-debug.log && rm -fr bower_components && rm -fr node_modules && rm -fr public && sudo -u $SUDO_USER npm install && cd ..
cd checkout && rm npm-debug.log && rm -fr bower_components && rm -fr node_modules && rm -fr public && sudo -u $SUDO_USER npm install && cd ..
cd api && rm npm-debug.log && rm -fr bower_components && rm -fr node_modules && npm rm -fr public && sudo -u $SUDO_USER npm install && cd ..

sudo -u $SUDO_USER make install
sudo -u $SUDO_USER make build

#START ENVIRONMENT
sudo docker-compose kill
sudo docker-compose rm
sudo docker-compose up &
