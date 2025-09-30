FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      mariadb-server netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Folders + permissions
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld && \
    chmod 755 /run/mysqld

# Custom server config
COPY conf/51-server.cnf /etc/mysql/mariadb.conf.d/51-server.cnf

# Init script
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

# init_db.sh will exec the server at the end (CMD is the binary)
ENTRYPOINT ["/init_db.sh"]
CMD ["mariadbd"]
