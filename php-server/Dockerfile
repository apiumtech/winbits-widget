FROM ubuntu:latest

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

CMD ["8000"]

RUN apt-get update && apt-get install php5-cli -y

RUN mkdir -p /var/server/

COPY ./entrypoint.sh /var/server/

ENTRYPOINT ["/var/server/entrypoint.sh"]
