#!/bin/bash
set -e

# Fix permissions for Laravel storage and cache directories
if [ -d "/var/www/php_project/storage" ]; then
    chown -R www-data:www-data /var/www/php_project/storage
    chmod -R 775 /var/www/php_project/storage
fi

if [ -d "/var/www/php_project/bootstrap/cache" ]; then
    chown -R www-data:www-data /var/www/php_project/bootstrap/cache
    chmod -R 775 /var/www/php_project/bootstrap/cache
fi

# Execute the original command
exec "$@"

