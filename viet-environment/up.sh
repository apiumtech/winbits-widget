#!/bin/sh

set -e

cd $(dirname $(readlink -f "$0"))

docker build -t winbits-widgets/nginx-server ../nginx-server
docker build -t winbits-widgets/php-server ../php-server

cp ../docker-compose.yml .

sed -i 's%nginxserver%winbits-widgets/nginx-server%g' docker-compose.yml
sed -i 's%phpserver%winbits-widgets/php-server%g' docker-compose.yml

docker-compose up
