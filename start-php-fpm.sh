#!/bin/bash
set -e

# Start PHP 7.4 FPM
if [ -f /usr/sbin/php-fpm7.4 ]; then
    echo "Starting PHP 7.4 FPM on port 9000..."
    # Override default config with our custom config
    php-fpm7.4 -F -y /etc/php/7.4/fpm/php-fpm-workspace-74.conf &
    PHP74_PID=$!
    echo "PHP 7.4 FPM started (PID: $PHP74_PID)"
fi

# Start PHP 8.4 or 8.3 FPM
if [ -f /usr/sbin/php-fpm8.4 ]; then
    echo "Starting PHP 8.4 FPM on port 9001..."
    php-fpm8.4 -F -y /etc/php/8.4/fpm/php-fpm-workspace-84.conf &
    PHP84_PID=$!
    echo "PHP 8.4 FPM started (PID: $PHP84_PID)"
elif [ -f /usr/sbin/php-fpm8.3 ]; then
    echo "Starting PHP 8.3 FPM on port 9001..."
    php-fpm8.3 -F -y /etc/php/8.3/fpm/php-fpm-workspace-83.conf &
    PHP83_PID=$!
    echo "PHP 8.3 FPM started (PID: $PHP83_PID)"
fi

# Keep script running and wait for all background processes
wait

