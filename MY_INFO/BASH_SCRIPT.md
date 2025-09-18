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