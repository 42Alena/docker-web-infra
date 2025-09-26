#!/bin/bash

# Safety options: prints every command before it runs (with arguments expanded)
set -euo pipefail
set -x

echo "[init_db.sh] Start running /init_db.sh"
echo "[init_db.sh] Check if MariaDB system database exists (folder /var/lib/mysql/mysql)"
if [ ! -d "/var/lib/mysql/mysql" ]; then
    
    echo "[init_db.sh] First run: MariaDB system database not found, initializing..."

	#recursive change user:group. if root=> install database fail
	chown -R mysql:mysql /var/lib/mysql


	mariadb-install-db  --user=mysql \
   						--basedir=/usr      \
   						--datadir=/var/lib/mysql
else
    
    echo "[init_db.sh] MariaDB system database already exists, skipping init."
fi

# start temporary MariaDB server (socket only, no TCP)
echo "[init_db.sh] Starting temporary MariaDB server..."
mariadbd --skip-networking \
         --socket=/run/mysqld/mysqld.sock \
         --datadir=/var/lib/mysql &
pid="$!"

# wait until server is ready
echo "[init_db.sh] Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done

# change root passw (no passw by default), create user1, database
echo "[init_db.sh] Running initial SQL setup..."
mysql --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
    CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASS}';     
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;             
    FLUSH PRIVILEGES;

    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

# optional debug: verify DB + user exist
echo "[init_db.sh] Verifying databases and grants..."   
mysql --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" -e "SHOW DATABASES; SHOW GRANTS FOR '${DB_USER}'@'%';" 



# stop temporary MariaDB server
echo "[init_db.sh] Shutting down temporary MariaDB server..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" shutdown





# replace this script with the main MariaDB server process (from CMD ["mariadbd"]  in Dockerfile)
echo "[init_db.sh] Starting the main MariaDB server..."
exec "$@"