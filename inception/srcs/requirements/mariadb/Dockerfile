FROM debian:bookworm

RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*

# Copy your own config + init script
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init_db.sh /docker-entrypoint-initdb.d/init_db.sh

EXPOSE 3306
CMD ["mysqld_safe"]  