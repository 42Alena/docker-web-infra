SHELL := /bin/bash

VM_DATA=/home/akurmyza/data
COMPOSE_FILE=srcs/docker-compose.yml
ENV_SRC=~/inception_srcs/.env
ENV_DST=srcs/.env

# ───────────────────────────────
# MAIN TARGETS
# ───────────────────────────────

all: env data up

env:
	@if [ ! -f $(ENV_DST) ]; then cp $(ENV_SRC) $(ENV_DST); fi

data:
	mkdir -p $(VM_DATA)/mariadb
	mkdir -p $(VM_DATA)/wordpress

up:
	docker compose -f $(COMPOSE_FILE) -p inception up -d --build

down:
	docker compose -f $(COMPOSE_FILE) -p inception down

clean:
	docker stop $$(docker ps -qa) || true
	docker rm $$(docker ps -qa) || true
	docker rmi -f $$(docker images -qa) || true
	docker volume rm $$(docker volume ls -q) || true
	docker network rm $$(docker network ls -q) 2>/dev/null || true

fresh: clean all

# ───────────────────────────────
# DEFENSE CHECKS
# ───────────────────────────────

ps:
	docker compose -f $(COMPOSE_FILE) -p inception ps

net:
	docker network ls
	docker network inspect inception

vols:
	ls -al $(VM_DATA)
	docker volume ls

dbcheck:
	docker exec -it mariadb mariadb -h mariadb \
	  -u$$(grep DB_USER $(ENV_DST) | cut -d= -f2) \
	  -p$$(grep DB_PASS $(ENV_DST) | cut -d= -f2) \
	  -D$$(grep DB_NAME $(ENV_DST) | cut -d= -f2) \
	  -e "SELECT user_login, user_pass FROM wp_users;"

dbshow:
	docker exec -it mariadb mariadb -uroot \
	  -p$$(grep DB_ROOT_PASS $(ENV_DST) | cut -d= -f2) \
	  -e "SHOW DATABASES;"

usershow:
	docker exec -it mariadb mariadb -uroot \
	  -p$$(grep DB_ROOT_PASS $(ENV_DST) | cut -d= -f2) \
	  -e "SELECT User, Host FROM mysql.user;"

persist:
	docker compose -f $(COMPOSE_FILE) -p inception down
	docker compose -f $(COMPOSE_FILE) -p inception up -d

nginxlogs:
	docker logs nginx --tail=50

wplogs:
	docker logs wordpress --tail=50

dblogs:
	docker logs mariadb --tail=50

# Fix DB user manually if needed (safety net)
fixdb:
	docker exec -i mariadb mariadb -uroot -p$$(grep DB_ROOT_PASS $(ENV_DST) | cut -d= -f2) \
	  -e "ALTER USER '$$(grep DB_USER $(ENV_DST) | cut -d= -f2)'@'%' IDENTIFIED BY '$$(grep DB_PASS $(ENV_DST) | cut -d= -f2)'; \
	      ALTER USER '$$(grep DB_USER $(ENV_DST) | cut -d= -f2)'@'localhost' IDENTIFIED BY '$$(grep DB_PASS $(ENV_DST) | cut -d= -f2)'; \
	      FLUSH PRIVILEGES;"
	@echo "  Fixed MariaDB user password for $$(grep DB_USER $(ENV_DST) | cut -d= -f2)"

# Run all checks together
defense: ps net vols dbshow usershow dbcheck
	@echo ""
	@echo "[Defense]  OK! checks completed."
	@echo "Next steps (manual in browser):"
	@echo "  1. Open https://akurmyza.42.fr (HTTPS only, not HTTP)."
	@echo "  2. Confirm WordPress loads (no install screen)."
	@echo "  3. Login as manager (admin role) → prove username is not 'admin'."
	@echo "     URL: https://akurmyza.42.fr/wp-login.php"
	@echo "  4. Add a comment / edit a page → show persistence."
	@echo "  5. Reboot VM to prove persistence:"
	@echo "       sudo reboot"
	@echo "     After reboot:"
	@echo "       cd ~/inception"
	@echo "       make all"
	@echo "       make ps"
	@echo "       open https://akurmyza.42.fr/"
	@echo ""

# ───────────────────────────────
# HELP
# ───────────────────────────────
help:
	@echo ""
	@echo " Inception – Defense Commands"
	@echo "───────────────────────────────"
	@echo "First time setup:"
	@echo "  make fresh   → Clean all Docker state + rebuild everything."
	@echo "                 Use this on a new VM to ensure volumes/folders are created correctly."
	@echo ""
	@echo "Everyday use:"
	@echo "  make all     → Setup env + data folders + start containers"
	@echo "  make down    → Stop containers"
	@echo "  make clean   → Full reset (as in eval sheet, stops/removes everything)"
	@echo ""
	@echo "Defense helpers:"
	@echo "  make ps        → Show running containers"
	@echo "  make net       → Show docker networks + inspect inception"
	@echo "  make vols      → Show host + docker volumes"
	@echo "  make dbshow    → Show databases (prove WP DB exists)"
	@echo "  make usershow  → Show DB users (prove DB users exist)"
	@echo "  make dbcheck   → Show WP users + hashed passwords"
	@echo "  make persist   → Restart containers (check persistence)"
	@echo ""
	@echo "Logs & fixes:"
	@echo "  make nginxlogs → Show Nginx logs"
	@echo "  make wplogs    → Show WordPress logs"
	@echo "  make dblogs    → Show MariaDB logs"
	@echo "  make fixdb     → Repair WP DB user if password mismatch"
	@echo ""
	@echo "Evaluation:"
	@echo "  make defense   → Run all checks together and print browser steps"
	@echo ""

.PHONY: all env data up down clean fresh ps net vols dbcheck dbshow usershow persist nginxlogs wplogs dblogs fixdb defense help
