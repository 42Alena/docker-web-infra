services:
  nginx:
    # ...
    depends_on: [wordpress]
    networks: [inception]
    volumes:
      - wordpress_data:/var/www/wordpress
    ports: ["443:443"]

  mariadb:
    # ...
    networks: [inception]
    expose: ["3306"]
    volumes:
      - mariadb_data:/var/lib/mysql

  wordpress:
    # ...
    depends_on: [mariadb]
    networks: [inception]
    expose: ["9000"]
    volumes:
      - wordpress_data:/var/www/wordpress

networks:
  inception:
    driver: bridge   # explicit network is mandatory

volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/mariadb   # → /home/akurmyza/data/mariadb on VM
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/wordpress # → /home/akurmyza/data/wordpress
