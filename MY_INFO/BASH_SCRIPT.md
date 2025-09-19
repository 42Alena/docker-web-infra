Tutorial:
https://www.freecodecamp.org/news/bash-scripting-tutorial-linux-shell-script-and-command-line-for-beginners/

## Inside container, open bash
* `docker exec -it mariadb bash`

## Check

`which bash`
# This line ensures the script always runs in Bash,

```bash
# Use bash shell to interpret this script
#!/bin/bash
```

* `#!` - **shebang** tells the operating system which program should run the script
* `/bin/bash` tells the system to run this script with the **Bash shell** (instead of sh, zsh, etc.).


# Safety options during writing bash script;
```bash
# Safety options: 
# -e = exit on error
# -u = treat unset vars as error
# -o pipefail = fail if any part of a pipe fails
# -x = print each command before running (debug)
set -euo pipefail
set -x
```

#First-run detection

**Purpose**

* We need to know if this is the **first time** MariaDB runs.
* If yes → we must initialize the database (system tables, users, etc.).
* If no → skip initialization and just start the server.
* This prevents destroying data inside your volume.

**Where to find it in container**

* The MariaDB **system database** lives at:

  ```
  /var/lib/mysql/mysql
  ```
* If this directory exists → MariaDB is already initialized.
* If it does not exist → first run, so we must initialize.

**How to test it in container**

1. Start your container with an **empty volume**.

   ```bash
   docker compose up -d mariadb
   docker exec -it mariadb ls /var/lib/mysql
   ```

   → You should **not** see a `mysql/` folder yet (first run).

2. After running the init script once, check again:

   ```bash
   docker exec -it mariadb ls /var/lib/mysql
   ```

   → You should now see `mysql/` plus other dirs (means initialized).

**Script lines with comments**

```bash
# If system DB not found → initialize MariaDB system tables
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[init_db.sh] First run: initializing MariaDB system tables..."

    # Ensure correct ownership (so mysql user can write here)
    chown -R mysql:mysql /var/lib/mysql

    # Initialize the MariaDB system database structure
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm

    echo "[init_db.sh] MariaDB system tables created."
else
    echo "[init_db.sh] MariaDB system database already exists, skipping init."
fi

```

---
Perfect, let’s break down those two commands line by line 👇

---

## 1. `chown -R mysql:mysql /var/lib/mysql`

* **`chown`** → change ownership (who owns files/folders).
* **`-R`** → recursive, apply to everything inside the folder.
* **`mysql:mysql`** → set both **user = mysql** and **group = mysql**.
* **`/var/lib/mysql`** → the path to MariaDB’s data directory.

👉 Why?
MariaDB **runs as the `mysql` user** (not root). If this folder is owned by root, MariaDB won’t be able to write there → startup will fail.
This guarantees correct permissions for the database engine.

**Test inside container**:

```bash
ls -ld /var/lib/mysql
```

You should see:

```
drwxr-xr-x  5 mysql mysql ...
```

(meaning owner = mysql, group = mysql).

---

## 2. init tables: mariadb-install-db for linux (myssql_install_db for windows)

 https://mariadb.com/docs/server/clients-and-utilities/deployment-tools/mariadb-install-db
 
 ```bash
 mariadb-install-db --user=mysql \
   --basedir=/usr      \
   --datadir=/var/lib/mysql
```

**Test inside container**:

1. First, remove `/var/lib/mysql/*` (only in test mode, don’t do in production).
2. Run `mysql_install_db ...` manually.
3. Check:

   ```bash
   ls /var/lib/mysql
   ```

   → You’ll now see directories like `mysql/`, `performance_schema/`, etc.

---
DOCKER:


Aha 👀 this is a very common Docker “gotcha”: you rebuilt the image, but your container is still using the **old layer** with the old `init_db.sh`. That’s why your logs still show the old `echo "I am running"` instead of your new `[init_db.sh] Start running /init_db.sh`.

Let’s fix this step by step 👇

---

## 1. Why it happens

* Docker caches build layers.
* If the file you `COPY` didn’t change in Docker’s eyes, it may reuse an old layer.
* Also, if you **remove the container** but not the image, `docker run` may reuse the old image.

---

## 2. Force rebuild with no cache

Run in your `srcs/requirements/mariadb/` folder:

```bash
docker build --no-cache -t mariadb .
```

* `--no-cache` → ignores all cached layers, ensures fresh copy.
* `-t mariadb` → tags it as `mariadb`.
* `.` → current folder as build context.

---

## 3. Remove old container + image

To be safe, clean up first:

```bash
docker stop mariadb
docker rm mariadb
docker rmi mariadb
```
or
```
docker compose down -v
docker compose up -d --build mariadb

docker compose ps            # shows status (Up/Restarting/Exited)
docker logs -f mariadb       # follow logs (Ctrl+C to stop following)

docker logs   mariadb

```

 same with docker compose: 
 ```bash
 docker compose down --rmi all -v
```
---

## 4. Restart with compose

Rebuild and start again:

```bash
docker compose up -d --build mariadb
```

* `--build` → forces rebuild before starting.

---

## 5. Check logs

Now:

```bash
docker logs mariadb
```

You should finally see:

```
[init_db.sh] Start running /init_db.sh
[init_db.sh] Check if MariaDB system database exists (folder /var/lib/mysql/mysql)
[init_db.sh] First run: MariaDB system database not found, initializing...
```

---

✅ **Summary**:

* Always use `--no-cache` if Docker seems to ignore changes.
* If using Compose, also use `--build`.
* Use `docker logs mariadb` to see the init script output.

---

```bash
 docker exec -it mariadb bash
 ```
## Enter the container

```bash
docker exec -it mariadb bash
ls -l /var/lib/mysql

```
mysql/                 <-- system database

Try connecting to MariaDB
```bash
mysql -u root
# type the password from your .env (DB_ROOT_PASS).
```
Verify databases
```bash
SHOW DATABASES;
EXIT;
exit
# Check logs outside container
docker logs mariadb
```

## Change root password (no passw for root at begin)

https://mariadb.com/docs/server/clients-and-utilities/deployment-tools/mariadb-install-db 

```
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
```
BUT! It was not working

`docker logs mariadb`
```
[init_db.sh] MariaDB system database already exists, skipping init.
ERROR 2002 (HY000): Can't connect to local server through socket '/run/mysqld/mysqld.sock' (2)
```
Need start temporary mdb server

run SQL for config table and users

stop it  temporary mdb server
## => Temporary MariaDB Server Commands
Perfect 👍 Let’s make a **Markdown snippet** you can drop straight into your docs/README.
This shows exactly how to **start and stop a temporary MariaDB server** inside the `init_db.sh` script.

---

##  Temporary MariaDB Server Commands (for `init_db.sh`) to run SQL setup before the real server starts:

```bash
# Start temporary MariaDB server (background)
mariadbd --skip-networking \
         --socket=/run/mysqld/mysqld.sock \
         --datadir=/var/lib/mysql &

# Store its PID (process ID) to control it later
pid="$!"

# Wait until server is ready
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done

# Run SQL commands against the temporary server
mysql --socket=/run/mysqld/mysqld.sock -u root -e "SELECT VERSION();"

# Stop the temporary server cleanly
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"$DB_ROOT_PASS" shutdown
```

---

### Explanation of each command

* `mariadbd --skip-networking` → starts MariaDB **without TCP**, only local socket.
* `--socket=/run/mysqld/mysqld.sock` → defines the socket path (client must use the same).
* `&` → runs in background so script can continue.
* `pid="$!"` → captures PID of last background process (optional, if you prefer to `kill $pid` instead of `mysqladmin shutdown`).
* `mysqladmin ping` → waits until the server is responsive.
* `mysql ...` → run SQL setup (create DB, users, etc.).
* `mysqladmin shutdown` → cleanly stops the temporary server.

## connect directly to the MariaDB server inside the container
```
docker exec -it mariadb mariadb -u root -p
```
enter pass for root from .env

# CHeck mariadb
```bash
#List all databases (should include your custom one, e.g. wordpress)
SHOW DATABASES;

# Switch into system DB mysql (where users are stored)  List all users 
USE mysql;
SELECT User, Host FROM user;


# SAME as up, but without changing to myscl database List all users (prove your wpuser exists)
SELECT User, Host FROM mysql.user;

# Check privileges for wpuser
SHOW GRANTS FOR 'wpuser'@'%';

# Switch into your DB (prove it works)
USE wordpress;

# Show tables (may be empty at first, but command must succeed)
SHOW TABLES;

EXIT;
```

# !Persistence test: Stop and start containers (without -v):
```
docker compose down
docker compose up -d

ocker exec -it mariadb mariadb -u root -p
```
###  | User        | Host      |
### | wpuser      | %         |
% is a wildcard that means any host
means → wpuser can connect from any IP / any hostname, not just localhost.

## SHOW GRANTS FOR 'wpuser'@'%';
## 'wpuser'@'%'
→ wpuser can log in from any machine (container-to-container, remote, etc.) if credentials match.