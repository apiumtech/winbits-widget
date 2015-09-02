#!/usr/bin/env bash

set -e
set -x

#DOWNLOAD PACKAGES
make install

#BUILD AND WATCH

#make watch_widget &
#make watch_checkout &
#make watch_api &

#START ENVIRONMENT
sudo docker-compose kill
sudo docker-compose rm
sudo docker-compose up &
