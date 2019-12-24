FROM php:5-apache
COPY index.php /var/www/html/index.php
RUN mkdir /var/www/html/health
COPY info.php /var/www/html/health/index.php
RUN chmod a+rx index.php
