#!/bin/sh
# Death Plan Switch container entrypoint.
#
# Replaces cron: runs the scheduler as www-data (the user Apache serves pages
# as, and the owner of the data files) every DPS_TICK_INTERVAL seconds, then
# hands over to Apache. The engine works from stored timestamps, so running
# more often than every 15 minutes is harmless.
set -eu

DATA="${DPS_DATA:-/data}"
INTERVAL="${DPS_TICK_INTERVAL:-300}"

mkdir -p "$DATA"
chown -R www-data:www-data "$DATA"

(
    while :; do
        runuser -u www-data -- php /var/www/html/cron.php || echo "dps: scheduler run failed" >&2
        sleep "$INTERVAL"
    done
) &

exec docker-php-entrypoint "$@"
