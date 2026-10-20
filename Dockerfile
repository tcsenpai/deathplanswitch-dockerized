# Death Plan Switch: self-contained image (Apache + PHP + built-in scheduler).
# See "Docker" in the README.
FROM php:8.3-apache

# openssl, mbstring, curl and posix are already compiled into the official image.
COPY docker/apache.conf /etc/apache2/conf-available/dps.conf
RUN a2enconf dps \
    && a2dismod -f autoindex \
    && mkdir -p /data \
    && chown www-data:www-data /data

COPY --chown=root:root . /var/www/html/
COPY docker/config.local.php /var/www/html/config.local.php
COPY docker/entrypoint.sh /usr/local/bin/dps-entrypoint
RUN chmod 755 /usr/local/bin/dps-entrypoint \
    && rm -rf /var/www/html/docker /var/www/html/Dockerfile /var/www/html/compose.yaml

ENV DPS_DATA=/data \
    DPS_TICK_INTERVAL=300

VOLUME ["/data"]
EXPOSE 80

HEALTHCHECK --interval=1m --timeout=5s --start-period=10s \
    CMD curl -fsS -o /dev/null http://127.0.0.1/index.php?p=login || exit 1

ENTRYPOINT ["dps-entrypoint"]
CMD ["apache2-foreground"]
