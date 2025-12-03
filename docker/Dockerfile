FROM matomo:apache

# 1. Configurar variables de entorno por defecto (se pueden sobreescribir en K8s)
ENV PHP_MEMORY_LIMIT=512M

# 2. Crear fichero de configuración PHP personalizado
# Ajustamos upload_max_filesize y post_max_size
RUN echo "upload_max_filesize = 512M" > /usr/local/etc/php/conf.d/zzz-matomo.ini && \
    echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini && \
    echo "memory_limit = \${PHP_MEMORY_LIMIT}" >> /usr/local/etc/php/conf.d/zzz-matomo.ini

# 3. Cambiar el puerto de escucha de Apache de 80 a 81
# Modificamos ports.conf y el virtualhost por defecto
RUN sed -i 's/Listen 80/Listen 81/g' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:81>/g' /etc/apache2/sites-available/000-default.conf

# Exponer el puerto 81
EXPOSE 81