#!/bin/sh

# Safety: exit on error (-e) and on unset vars (-u). No -x to avoid leaking secrets.
set -eu

# wait indefinitely for MariaDB
until nc -z mariadb 3306 2>/dev/null; do
  echo "[init_wp] waiting for MariaDB..."
  sleep 1
done

# same as in Dockerfile already set WORKDIR /var/www/wordpress 
# cd /var/www/wordpress

#  @Task: creating "manager"(word "admin" in subject not alllowed) and user
if ! wp core is-installed --allow-root; then
  echo "[init_wp] creating wp-config.php..."
  wp config create --allow-root \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}"

  echo "[init_wp] core installing WP and creating manager(word admin not allowed)"
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

# run php-fpm in foreground with pid 1  
exec php-fpm8.2 -F
