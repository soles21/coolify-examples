#!/bin/bash
set -e

if [ "$RAILPACK_SKIP_MIGRATIONS" != "true" ]; then
  php artisan migrate --force
fi

php artisan storage:link || true
php artisan optimize:clear
php artisan optimize

(while true; do php artisan queue:work --sleep=3 --tries=3 --max-time=3600; done) &
php artisan schedule:work &

trap 'kill $(jobs -p) 2>/dev/null || true' EXIT INT TERM

exec docker-php-entrypoint --config /Caddyfile --adapter caddyfile
