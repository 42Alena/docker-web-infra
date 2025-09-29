#!/bin/sh
set -eu

echo "[init_wp] Waiting for MariaDB to be ready..."
until mariadb -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "[init_wp] .. still waiting for MariaDB..."
  sleep 2
done
echo "[init_wp] ✅ MariaDB is ready!"

# WordPress install (WORKDIR is already /var/www/wordpress from Dockerfile)
if ! wp core is-installed --allow-root; then
  echo "[init_wp] creating wp-config.php..."
  wp config create --allow-root \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}"

  echo "[init_wp] core installing WP and creating manager (not 'admin')"
  wp core install --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  echo "[init_wp] creating normal user..."
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASS}" \
    --role=author \
    --allow-root
fi

exec php-fpm8.2 -F
