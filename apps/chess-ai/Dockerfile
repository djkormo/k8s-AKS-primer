FROM alpine:3.8

RUN apk --update add \
    curl php-apache2 php-cli php-json php-mbstring php-phar php-openssl && \
    rm -f /var/cache/apk/* && \
    curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer && \
    mkdir -p /var/www/html/ && chown -R apache:apache /var/www/html


#RUN apk update && apk upgrade
#RUN apk add --no-cache apache2 bash git php7 php7-fpm php7-opcache openrc

RUN mkdir /run/apache2

COPY src/ /var/www/html/
COPY etc/apache2/httpd.conf /etc/apache2/httpd.conf
COPY etc/apache2/sites/ /etc/apache2/sites/
COPY etc/php/php.ini /etc/php7/php.ini


RUN rc-service apache2 restart
RUN git clone https://github.com/djkormo/simple-chess-ai

RUN cd simple-chess-ai && cp -R . /var/www/localhost/htdocs/ && cd .. && rm -r simple-chess-ai/


EXPOSE 80/tcp

ENTRYPOINT ["httpd"]
CMD ["-D","FOREGROUND"]