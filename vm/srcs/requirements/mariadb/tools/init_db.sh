#!/bin/bash
# Safety options:
#  -e : exit immediately if a command exits with non-zero status
#  -u : treat unset variables as an error
#  -o pipefail : pipeline fails if any command fails
#  -x : print each command before executing (helps during defense)
set -euo pipefail
set -x

echo "[init_db.sh] Start running /init_db.sh"

FIRST_RUN=0
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[init_db.sh] First run: initializing system database..."
    FIRST_RUN=1

    # Ensure correct ownership (mysql:mysql) on data dir
    chown -R mysql:mysql /var/lib/mysql

    # Initialize MariaDB system tables (creates /var/lib/mysql/mysql)
    mariadb-install-db --user=mysql \
                       --basedir=/usr \
                       --datadir=/var/lib/mysql
fi

# Start a temporary MariaDB (socket only, no TCP) to run bootstrap/ensure SQL
echo "[init_db.sh] Starting temporary MariaDB (socket only)..."
mariadbd --skip-networking \
         --socket=/run/mysqld/mysqld.sock \
         --datadir=/var/lib/mysql &
pid="$!"

# Wait until the server is ready (pings via UNIX socket)
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done
echo "[init_db.sh] Temporary MariaDB is ready."

if [ "$FIRST_RUN" -eq 1 ]; then
    echo "[init_db.sh] Bootstrapping root password, DB and users (no password yet)."
    # On fresh datadir, root@localhost has no password → connect without -p
    mysql --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
        -- Set root password (socket user)
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

        -- Create application database
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

        -- Create application users
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

        CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';

        FLUSH PRIVILEGES;
EOSQL
fi

# Always ensure DB and users exist (idempotent; safe on subsequent boots)
echo "[init_db.sh] Ensuring DB and users exist (idempotent)."
mysql --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

    CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';

    -- Keep credentials in sync if they changed in .env
    ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
    ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';

    FLUSH PRIVILEGES;
EOSQL

# Stop the temporary server cleanly
echo "[init_db.sh] Shutting down temporary MariaDB..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" shutdown

# Replace PID 1 with the main MariaDB server process
echo "[init_db.sh] Starting main MariaDB..."
exec "$@"
