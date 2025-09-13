FROM debian:bookworm

RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*

# RUN addgroup mysql 
RUN adduser mysql mysql

RUN mkdir -p /var/lib/mysql /run/mysqld; \
	chown -R mysql:mysql /var/lib/mysql /run/mysqld; \
	chmod 1777 /run/mysqld; 

# Copy   own config + init script
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy own  init script
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

# First run executes init script, then CMD starts server
ENTRYPOINT [ "/init_db.sh" ]

USER mysql
CMD ["mariadbd"]  