FROM debian:bookworm

RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server  \
    netcat-openbsd && \
	rm -rf /var/lib/apt/lists/*


# Ensure correct permissions
RUN mkdir -p /var/lib/mysql /run/mysqld; \
	chown -R mysql:mysql /var/lib/mysql /run/mysqld; \
	chmod 755 /run/mysqld; 

# Leave the original 50-server.cnf untouched
# Add custom 51-server.cnf (loaded later, overrides needed settings) to edit config then
COPY conf/51-server.cnf /etc/mysql/mariadb.conf.d/

# Copy own  init script
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

# ENTRYPOINT runs script init_db.sh (PID 1). init_db.sh must end with: exec "$@"  → hands off to CMD.
ENTRYPOINT ["/init_db.sh"]

# CMD supplies the server binary to exec at the end of init_db.sh (no backgrounding).
CMD ["mariadbd"] 