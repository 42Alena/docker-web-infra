# The 50-server.cnf file is a MariaDB configuration file

Official MariaDB Documentation

https://mariadb.com/docs/server/server-management/install-and-upgrade-mariadb/configuring-mariadb/configuring-mariadb-with-option-files 
- 50-server.cnf is the default server configuration file for MariaDB on Debian/Ubuntu systems.

- It lives in /etc/mysql/mariadb.conf.d/.

- Why "50-"?

	- MariaDB reads .cnf files in numeric + alphabetical order.
	
	So:

	- 50-client.cnf is loaded before 50-server.cnf.

	- If the same option appears in both, the last one wins.

	- Files starting with 60- override files starting with 50-.

- That’s why my custom server settings belong in 50-server.cnf.

	- Files with smaller numbers (like 10-...cnf) are loaded first.

	- Higher numbers (like 50-server.cnf) override previous settings.
	→ This allows modular configs: you can add my own 60-custom.cnf to override defaults.

		- 10– files → basic defaults.

		- 50– files → main configs (server, client, mysqld_safe).

		- 60– files → optional/tuning/extra engines.

## 50-server.cnf

50-server.cnf = the main MariaDB server configuration file. The 50- prefix ensures it overrides earlier configs. You customize it so MariaDB runs correctly inside my container with Docker volumes.

## What 50-server.cnf contains:
It sets server-wide options for the mysqld process, for example:
```
[mysqld]
datadir = /var/lib/mysql
socket  = /run/mysqld/mysqld.sock
bind-address = *
port = 3306
user = mysql
```
These define where MariaDB stores data, how it listens for connections, and what user runs it.

## In Inception:

### 1. variant - override original, but dont see it original info.:

`COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
`
## 2. Variant(that i did):  
```
# Leave the original 50-server.cnf untouched
# Add custom 51-server.cnf (loaded later, overrides needed settings)
COPY conf/51-server.cnf /etc/mysql/mariadb.conf.d/
```
leave original 50-server.cnf to compare for defense and use. I named and saved 51-server.cnf and will  copy from my repo into the container. It will be original 50 and my 51. My 51 will executes after 50 and override some settings.



# 1. Start my MariaDB container

```bash
docker compose up -d mariadb
```
- `docker` compose → uses my docker-compose.yml.

- `up` → start services.

- `-d` → run in background.

- `mariadb` → only start the mariadb service.

# 2. Open a shell inside the running container
```bash
docker exec -it mariadb bash
```
- `docker exec` → run a command inside an existing container.

- `-it` → interactive terminal mode.

- `mariadb` → container name (must match what’s in my docker-compose.yml).

- `bash` → start a shell session inside it.

Now you are inside the MariaDB container.

# 3. Navigate to the config directory
```
cd /etc/mysql/mariadb.conf.d
ls -l
```
You should see something like:
`
-rw-r--r-- 1 root root  XXXX Jan  1 00:00 50-server.cnf`

# 4. Read the file
```
cat 50-server.cnf
less 50-server.cnf
```

- cat → prints the file contents.

   This shows exactly what MariaDB is using.

- `less 50-server.cnf` - 
(For easier browsing: less lets you scroll with arrows, quit with q).

# 5. Confirm MariaDB loaded it

Inside the container, run:
```
mariadbd --verbose --help | grep -A 1 "Default options"
```

This prints all the config paths MariaDB checks at startup (you will see /etc/mysql/mariadb.conf.d/50-server.cnf in the list).

✅ That’s how you find and inspect 50-server.cnf inside the container.
It’s always under /etc/mysql/mariadb.conf.d/, unless you override it in my Dockerfile.


# my config 51-server.cnf 

```bash
[mysqld]
datadir     = /var/lib/mysql
socket      = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
port        = 3306
user        = mysql
```
Explanation:

## [section-name]
`[mysqld]` → section that applies to the MariaDB server process.

The MariaDB configuration files (.cnf) follow the INI file format:

- Sections are marked with square brackets [section-name].
	Inside each section you put key = value options.

- [mysqld] is the section for the MariaDB server daemon process (mysqld), the main database engine) This is what runs inside my container.

- Everything under [mysqld] applies only when the database server runs.

    Example: port number, bind address, data directory, etc.





## Store data in my Docker volume →
`datadir = /var/lib/mysql` → where database files live. Must match my Docker volume mount.
This is where MariaDB saves databases. In Docker Compose, you mount this path to my host (~/data/mariadb) → that’s what ensures persistence after reboot.

## Use the socket path that matches Debian defaults
- `socket = /run/mysqld/mysqld.sock` → local Unix socket for internal tools (not much needed in containers, but safe to leave).
This allows internal tools (like mysql client) to talk to the server.

## Bind to all interfaces, not only localhost
- `bind-address=0.0.0.0` → instead of 127.0.0.1, allows connections from other containers (WordPress).
If you leave the default 127.0.0.1, WordPress (running in another container) won’t be able to connect.
With 0.0.0.0, MariaDB listens to the internal Docker network.

## Use the standard MySQL/MariaDB port 
- `port=3306` → the standard MySQL/MariaDB port.
WordPress expects 3306 by default.

## Run as non-root user 
- `user=mysql` → ensures MariaDB runs as the proper non-root user inside the container.
Best practice: MariaDB process shouldn’t run as root.
