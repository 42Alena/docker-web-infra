https://hub.docker.com/_/mariadb

https://github.com/MariaDB/mariadb-docker

# Dockerfile
```
RUN apt update && \                    # Update the package list inside the container
    apt install -y \                   # Install packages (-y auto-confirms "yes")
      --no-install-recommends \        # Don’t pull in extra recommended packages
      --no-install-suggests \          # Don’t pull in optional suggested packages
      mariadb-server && \              # Install only mariadb-server
    rm -rf /var/lib/apt/lists/*        # Clean up cached package lists → keeps image smaller
```
# Port  MDB internal   
	EXPOSE 3306  
 # Run MDB server in foreground (not background)           
	CMD ["mysqld_safe"]     

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
COPY tools/init_db.sh /docker-entrypoint-initdb.d/init_db.sh
```
tools/init_db.sh = my initialization script (in srcs/requirements/mariadb/tools/).

Destination path = /docker-entrypoint-initdb.d/init_db.sh inside the container.

By convention (from MariaDB/MySQL design):
- Any .sh or .sql file inside /docker-entrypoint-initdb.d/ is executed the first time the DB starts (when /var/lib/mysql is empty).

So when my container starts, Docker runs my script automatically.

 Why I need it
- Subject requires that my database and users are created via environment variables, not hardcoded