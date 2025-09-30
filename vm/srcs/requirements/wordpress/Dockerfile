FROM debian:bookworm

# PHP-FPM + MySQL extension + tools
# - ca-certificates: trust store for HTTPS
# - curl, tar, unzip, netcat: utilities used during build and init
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      php8.2-fpm php8.2-mysql mariadb-client \
      curl ca-certificates tar unzip netcat-openbsd && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# php-fpm: listen on TCP:9000 (not UNIX socket) and keep env visible
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's|^;*clear_env = .*|clear_env = no|' /etc/php/8.2/fpm/pool.d/www.conf

# WordPress download + unpack (TLS verified thanks to ca-certificates)
RUN mkdir -p /var/www && \
    curl -fsSL https://wordpress.org/latest.tar.gz -o /var/www/latest.tar.gz && \
    tar -xzf /var/www/latest.tar.gz -C /var/www && \
    rm /var/www/latest.tar.gz && \
    chown -R root:root /var/www/wordpress

# WP-CLI (official build phar)
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

WORKDIR /var/www/wordpress

# Init script (waits for DB, generates wp-config.php, installs WP)
COPY tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN chmod +x /usr/local/bin/init_wp.sh

ENTRYPOINT ["/usr/local/bin/init_wp.sh"]
CMD ["php-fpm8.2", "-F"]
