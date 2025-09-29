
FROM debian:bookworm

# Install PHP, MariaDB client, and helpers
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y php8.2-fpm php8.2-mysql mariadb-client \
                       wget curl tar unzip netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Configure php-fpm to listen on TCP port 9000 instead of socket
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf \
 && sed -i 's|^;*clear_env = .*|clear_env = no|' /etc/php/8.2/fpm/pool.d/www.conf

# Download and extract WordPress
# @Task: php-fpm only (no nginx), 
# https://www.php.net/downloads.php?usage=web&os=linux&osvariant=linux-debian&version=8.2
RUN wget https://wordpress.org/latest.tar.gz -P /var/www && \
tar -xzf /var/www/latest.tar.gz -C /var/www && \
rm /var/www/latest.tar.gz && \
chown -R root:root /var/www/wordpress

# Install WP-CLI
# https://make.wordpress.org/cli/handbook/guides/installing/
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Optional: set working directory to simplify init script
WORKDIR /var/www/wordpress

# Copy init script (responsible for wp-config + install)
COPY tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN chmod +x /usr/local/bin/init_wp.sh

ENTRYPOINT ["/usr/local/bin/init_wp.sh"]

CMD ["php-fpm8.2", "-F"]



