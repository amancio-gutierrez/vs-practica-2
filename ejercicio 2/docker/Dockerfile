FROM matomo:apache

ENV PHP_MEMORY_LIMIT=512M


RUN echo "upload_max_filesize = 512M" > /usr/local/etc/php/conf.d/zzz-matomo.ini && \
    echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini && \
    echo "memory_limit = \${PHP_MEMORY_LIMIT}" >> /usr/local/etc/php/conf.d/zzz-matomo.ini && \
    echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/zzz-matomo.ini


RUN sed -i 's/Listen 80/Listen 81/g' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:81>/g' /etc/apache2/sites-available/000-default.conf

EXPOSE 81