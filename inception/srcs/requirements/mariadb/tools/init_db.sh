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

#change root passw(was no passw)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;

# setup database, users, permissions, etc.. 

# create database for ENV_XXX
# create user if not exist with passw 
# grant permssions to database for user
# if init.sql exists - import db  


# run everything in CMD 
exec "$@"