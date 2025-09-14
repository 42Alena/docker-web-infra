# MARIADB

https://mariadb.com/
https://hub.docker.com/_/mariadb
https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide
https://github.com/MariaDB/mariadb-docker

#  IF not created folder yet =>  create the data folders on your host:
(In the school VM you’ll switch to /home/<login>/data/... — but on macOS, /Users/... is correct.)

`mkdir -p ~/data/mariadb`

`mkdir -p ~/data/wordpress`

On macOS, this expands to /Users/alenakurmyza/data/....
in Docker compose:
```
	volumes:
	...   

	device: /Users/alenakurmyza/data/mariadb   #  real path on your Mac`
```
### Then rebuild and run again
```
docker compose down -v                # clean old containers + volumes
docker compose up -d mariadb
```



# Dockerfile
```
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
    mariadb-server && \
    rm -rf /var/lib/apt/lists/*
```
- Installs only MariaDB server.

- -y → auto-confirm yes.

- --no-install-recommends --no-install-suggests → prevents installing extra unnecessary packages → smaller image.

- rm -rf /var/lib/apt/lists/* → cleans package cache, best practice for smaller images.

# Port  MDB internal = 3306
`EXPOSE 3306 ` 

Documents the DB port.

⚠️ Important: in docker-compose.yml, use expose: "3306" (internal only), not ports: "3306:3306" — only WordPress should reach MariaDB, not the host.


#  give MariaDB my custom config.
```
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
```
- conf/50-server.cnf = my custom MariaDB configuration file (I keep it in my repo under srcs/requirements/mariadb/conf/).

- Destination path = /etc/mysql/mariadb.conf.d/50-server.cnf inside the container.

- When MariaDB starts, it loads all config files from /etc/mysql/mariadb.conf.d/.

- By copying my file here, I override default config (port, bind address, data directory, etc.).
```
[mysqld]
datadir=/var/lib/mysql
bind-address=0.0.0.0    # allow connections from wordpress container
port=3306
```
# initializes DB and users on first start.
```
# Copy own  init script
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

...
ENTRYPOINT [ "/init_db.sh" ]
```
In official MariaDB/MySQL Docker Hub images, there is a special folder:

`/docker-entrypoint-initdb.d/`
→ Scripts placed there run automatically when the container starts.

But in Inception  not allowed to use official images
 Why  init_db.sh  is neded?  
- Subject requires that my database and users are created via environment variables, not hardcoded


---
# Run MDB server in foreground (not background)           
`CMD ["mysqld_safe"]     `

https://mariadb.com/docs/server/server-management/starting-and-stopping-mariadb/mariadbd-safe 

- mysqld_safe is a wrapper script provided by MySQL/MariaDB.
- Its job is to start the real MariaDB server process (mysqld) in a safe way.
Starts mysqld (the database daemon).
- compare to CMD ["mysqld"] simpler, CMD ["mysqld_safe"] gives you automatic restart and logging.

That’s the real program that listens on port 3306 and handles SQL queries.

Adds safety features:

- Restarts mysqld automatically if it crashes.

- Logs errors to the MariaDB log file.

- Sets some useful defaults.

- Runs in foreground (so Docker sees it as PID 1).

Why it’s good in Docker

- In Docker, the main process (PID 1) must run in foreground.

- If PID 1 exits → container stops.

- Subject forbids hacks like tail -f /dev/null or sleep infinity

mysqld_safe is the safe wrapper around the MariaDB server process. It starts the real mysqld daemon, restarts it if it crashes, and writes errors to logs. In Docker, it runs in the foreground as PID 1, so the container stays alive without hacks like tail -f, which are forbidden by the subject.

# TEST!
Perfect 👍 — I’ll make you a **full exam-style test table** for MariaDB, including:

* All useful `docker` and `docker compose` commands
* All database checks
* What the evaluator will expect (based on eval sheet).

---

# 🐬 MariaDB — Full Test & Defense Checklist

| Step                              | **Docker Compose way** (from project root)                    | **Plain Docker way**                                  | Explanation / What evaluator checks                                                        |
| --------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| 1. Build image                    | `docker compose build mariadb`                                | `docker build -t mariadb ./srcs/requirements/mariadb` | Image must be built from your **own Dockerfile**, not pulled from DockerHub.               |
| 2. Start container                | `docker compose up -d mariadb`                                | `docker run -d --name mariadb mariadb`                | Starts MariaDB in background. Must not crash.                                              |
| 3. Check container status         | `docker compose ps`                                           | `docker ps`                                           | Verify container is up.                                                                    |
| 4. Check volumes                  | `docker volume ls`                                            | `docker volume ls`                                    | Must see a `mariadb` volume.                                                               |
| 5. Inspect volume path            | `docker volume inspect srcs_mariadb_data`                     | `docker volume inspect <volume_name>`                 | Must contain `/home/<login>/data/mariadb` (eval sheet requirement).                        |
| 6. Enter running container        | `docker exec -it mariadb bash`                                | `docker exec -it mariadb bash`                        | Evaluator will ask: *“Show me how to log into the DB.”*                                    |
| 7. Connect to MariaDB             | `mysql -u root -p` (enter `${SQL_ROOT_PASSWORD}` from `.env`) | Same                                                  | Must succeed.                                                                              |
| 8. Show databases                 | `SHOW DATABASES;`                                             | Same                                                  | Must see system DBs + your `${SQL_DATABASE}` (proves `init_db.sh` worked).                 |
| 9. Select DB                      | `USE ${SQL_DATABASE};`                                        | Same                                                  | Switch to your DB.                                                                         |
| 10. Show tables                   | `SHOW TABLES;`                                                | Same                                                  | Should not be empty if WordPress connected. At least system tables exist.                  |
| 11. Check users                   | `SELECT User, Host FROM mysql.user;`                          | Same                                                  | Must see root and your `${SQL_USER}`. Admin username must NOT contain “admin” (eval rule). |
| 12. Test login as normal user     | `mysql -u ${SQL_USER} -p` (enter `${SQL_PASSWORD}`)           | Same                                                  | Confirms privileges granted in `init_db.sh`.                                               |
| 13. Create test table             | `CREATE TABLE test (id INT);`                                 | Same                                                  | Verifies DB is writable.                                                                   |
| 14. Drop test table               | `DROP TABLE test;`                                            | Same                                                  | Clean up after test.                                                                       |
| 15. Exit                          | `EXIT;` → from MySQL <br> `exit` → from container             | Same                                                  | Leave cleanly.                                                                             |
| 16. Restart VM (persistence test) | Restart → `docker compose up -d`                              | Restart → `docker start mariadb`                      | Evaluator checks persistence: DB and WordPress data must still exist after reboot.         |

---

## ✅ What evaluators check specifically (from eval sheet)

* There is a **Dockerfile for MariaDB**.
* Container **starts without crash**.
* There is a **dedicated volume** bound to `/home/<login>/data/mariadb`.
* Student can **log into DB** (`mysql -u root -p`).
* The database is **not empty** (must show your `${SQL_DATABASE}`).
* User creation & privileges work (`${SQL_USER}`).
* Data is **persistent after reboot**.

---

👉 Do you want me to now prepare the **exact one-liner** that evaluators often ask for (connect directly without opening bash)?
