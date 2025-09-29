#!/bin/bash

# Safety options
set -euo pipefail
set -x

echo "[init_db.sh] Start running /init_db.sh"

# Check if MariaDB system database already exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[init_db.sh] First run: initializing system database..."

    # Fix ownership for mariadb
    chown -R mysql:mysql /var/lib/mysql

    # Initialize system database
    mariadb-install-db --user=mysql \
                       --basedir=/usr \
                       --datadir=/var/lib/mysql

    # Start temporary MariaDB (socket only, no TCP yet)
    echo "[init_db.sh] Starting temporary MariaDB..."
    mariadbd --skip-networking \
             --socket=/run/mysqld/mysqld.sock \
             --datadir=/var/lib/mysql &
    pid="$!"

    # Wait until MariaDB is ready
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        sleep 1
    done

    # Run initial SQL setup
    echo "[init_db.sh] Running initial SQL setup..."
    mysql --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
        -- Root password
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

        -- WordPress database
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

        -- WordPress user for containers
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

        -- WordPress user for localhost (so CLI inside container also works)
        CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';

        FLUSH PRIVILEGES;
EOSQL

    # Shutdown temporary server
    echo "[init_db.sh] Shutting down temporary MariaDB..."
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" shutdown
else
    echo "[init_db.sh] MariaDB system database already exists, skipping init."
fi

# Start main MariaDB server (replace process)
echo "[init_db.sh] Starting main MariaDB..."
exec "$@"
