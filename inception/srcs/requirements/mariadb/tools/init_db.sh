#!/bin/bash

# Safety options:
# -e : exit on error
# -u : error on unset variables
# -o pipefail : exit if any command in a pipeline fails
# -x : print commands before executing (debug mode)
set -euo pipefail
set -x

echo "[init_db.sh] Start running /init_db.sh"

# Check if MariaDB system database already exists
# The folder /var/lib/mysql/mysql is created only after first initialization
echo "[init_db.sh] Check if MariaDB system database exists (folder /var/lib/mysql/mysql)"
if [ ! -d "/var/lib/mysql/mysql" ]; then
    
    echo "[init_db.sh] First run: MariaDB system database not found, initializing..."

    # Fix ownership:
    # recursive change of user:group to mysql:mysql
    # If files belong to root → mariadb-install-db fails
    chown -R mysql:mysql /var/lib/mysql

    # Initialize system database
    mariadb-install-db --user=mysql \
                       --basedir=/usr \
                       --datadir=/var/lib/mysql

    # Start temporary MariaDB server (socket only, no TCP yet)
    echo "[init_db.sh] Starting temporary MariaDB server..."
    mariadbd --skip-networking \
             --socket=/run/mysqld/mysqld.sock \
             --datadir=/var/lib/mysql &
    pid="$!"

    # Wait until server is ready to accept connections
    echo "[init_db.sh] Waiting for MariaDB to be ready..."
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        sleep 1
    done

    # Run initial SQL setup:
    # 1. Set root password (localhost only)
    # 2. Create WordPress database
    # 3. Create WordPress user and grant privileges
    echo "[init_db.sh] Running initial SQL setup..."
    mysql --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Stop temporary MariaDB server gracefully
    echo "[init_db.sh] Shutting down temporary MariaDB server..."
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" shutdown

else
    echo "[init_db.sh] MariaDB system database already exists, skipping init."
fi

# Finally: replace this script with the main MariaDB server process
# CMD in Dockerfile is ["mariadbd"], so "$@" = mariadbd
echo "[init_db.sh] Starting the main MariaDB server..."
exec "$@"
