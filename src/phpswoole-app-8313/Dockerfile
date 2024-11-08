FROM phpswoole/swoole:php8.3

# Install PostgreSQL PDO extension
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

WORKDIR /app
COPY . .

# Run Swoole server
CMD ["php", "server.php"]
