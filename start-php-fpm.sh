#!/bin/bash
set -e

# Function to handle shutdown
cleanup() {
    echo "Shutting down PHP-FPM..."
    if [ ! -z "$PHP74_PID" ]; then
        kill -TERM "$PHP74_PID" 2>/dev/null || true
    fi
    if [ ! -z "$PHP84_PID" ]; then
        kill -TERM "$PHP84_PID" 2>/dev/null || true
    fi
    wait
    exit 0
}

# Trap signals
trap cleanup SIGTERM SIGINT

# Start PHP 7.4 FPM
if [ -f /usr/sbin/php-fpm7.4 ]; then
    echo "Starting PHP 7.4 FPM on port 9000..."
    php-fpm7.4 -F -y /etc/php/7.4/fpm/php-fpm-workspace-74.conf &
    PHP74_PID=$!
    echo "PHP 7.4 FPM started (PID: $PHP74_PID)"
fi

# Start PHP 8.4 FPM
if [ -f /usr/sbin/php-fpm8.4 ]; then
    echo "Starting PHP 8.4 FPM on port 9001..."
    php-fpm8.4 -F -y /etc/php/8.4/fpm/php-fpm-workspace-84.conf &
    PHP84_PID=$!
    echo "PHP 8.4 FPM started (PID: $PHP84_PID)"
fi

# Wait for all background processes
echo "PHP-FPM services are running. Waiting for processes..."
wait

