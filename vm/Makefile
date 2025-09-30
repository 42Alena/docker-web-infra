SHELL := /bin/bash

VM_DATA=/home/akurmyza/data
COMPOSE_FILE=srcs/docker-compose.yml
ENV_SRC := $(HOME)/inception_srcs/.env
ENV_DST=srcs/.env

# ───────────────────────────────
# MAIN TARGETS
# ───────────────────────────────

all: env data up

env:
	@if [ ! -f $(ENV_DST) ]; then \
		if [ -f "$(ENV_SRC)" ]; then \
			echo "Info: copying $(ENV_SRC) → $(ENV_DST)"; \
			cp "$(ENV_SRC)" "$(ENV_DST)"; \
		else \
			echo "Error: $(ENV_DST) not found and $(ENV_SRC) missing"; \
			exit 1; \
		fi; \
	fi

data:
	@install -d -m 755 $(VM_DATA)/mariadb
	@install -d -m 755 $(VM_DATA)/wordpress
	@chown -R $$(id -u):$$(id -g) $(VM_DATA) 2>/dev/null || true

# Start containers WITHOUT rebuild
up:
	docker compose -f $(COMPOSE_FILE) -p inception up -d

# Start WITH rebuild
build:
	docker compose -f $(COMPOSE_FILE) -p inception up -d --build

down:
	docker compose -f $(COMPOSE_FILE) -p inception down

# Heavy clean + wipe persisted folders then recreate
clean:
	@if [ -f "$(COMPOSE_FILE)" ] && [ -f "$(ENV_DST)" ]; then \
		docker compose -f $(COMPOSE_FILE) -p inception down -v --remove-orphans || true; \
	fi
	-@docker rm -f $$(docker ps -aq) 2>/dev/null || true
	-@docker rmi -f $$(docker images -q) 2>/dev/null || true
	-@docker volume rm -f $$(docker volume ls -q) 2>/dev/null || true
	-@docker network rm $$(docker network ls -q | grep -vE '^(bridge|host|none)$$') 2>/dev/null || true
	@echo "Info: deleting persisted folders at $(VM_DATA) (sudo if required)"
	@rm -rf $(VM_DATA)/mariadb $(VM_DATA)/wordpress 2>/dev/null || sudo rm -rf $(VM_DATA)/mariadb $(VM_DATA)/wordpress || true
	@echo "Info: recreating folders with correct ownership"
	@install -d -m 755 $(VM_DATA)/mariadb $(VM_DATA)/wordpress
	@chown -R $$(id -u):$$(id -g) $(VM_DATA) 2>/dev/null || true

# Fresh = full reset + first-time build + up
fresh:
	@echo "Info: cleaning everything"
	$(MAKE) clean
	@echo "Info: ensuring $(ENV_DST) exists"
	@if [ ! -f $(ENV_DST) ]; then \
		if [ -f "$(ENV_SRC)" ]; then \
			cp "$(ENV_SRC)" "$(ENV_DST)"; \
		else \
			echo "Error: $(ENV_DST) not found and $(ENV_SRC) missing"; \
			exit 1; \
		fi; \
	fi
	@echo "Info: starting from scratch (build + up)"
	$(MAKE) build
	@echo "Info: containers are up"

# ───────────────────────────────
# CHECKS
# ───────────────────────────────

ps:
	docker compose -f $(COMPOSE_FILE) -p inception ps

net:
	docker network ls
	docker network inspect inception

vols:
	docker volume ls
	docker volume inspect wordpress_data
	docker volume inspect mariadb_data

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

fixdb:
	docker exec -i mariadb mariadb -uroot -p$$(grep DB_ROOT_PASS $(ENV_DST) | cut -d= -f2) \
	  -e "ALTER USER '$$(grep DB_USER $(ENV_DST) | cut -d= -f2)'@'%' IDENTIFIED BY '$$(grep DB_PASS $(ENV_DST) | cut -d= -f2)'; \
	      ALTER USER '$$(grep DB_USER $(ENV_DST) | cut -d= -f2)'@'localhost' IDENTIFIED BY '$$(grep DB_PASS $(ENV_DST) | cut -d= -f2)'; \
	      FLUSH PRIVILEGES;"
	@echo "Fixed MariaDB user password for $$(grep DB_USER $(ENV_DST) | cut -d= -f2)"

defense: ps net vols dbshow usershow dbcheck
	@echo ""
	@echo "All checks completed"
	@echo "Next steps:"
	@echo "  1. Open site (HTTPS only): https://akurmyza.42.fr"
	@echo "  2. Confirm WordPress loads (no install screen)."
	@echo "  3. Login as manager (prove username != admin): https://akurmyza.42.fr/wp-login.php"
	@echo "  4. Add a comment or edit a page to show persistence."
	@echo "  5. Restart VM to prove persistence: sudo reboot; then 'make all' and re-check."

help:
	@echo "First time on a new VM: 'make fresh' (full clean, build, up)."
	@echo "Everyday: 'make all' (env + data + up), then 'make defense' to check."
	@echo "Other: down, clean, build, ps, net, vols, dbshow, usershow, dbcheck, persist, logs."
	@echo "\n\nfresh     : Full reset + rebuild + start; use on NEW VM or when things are messy."
	@echo "all       : Ensure .env + data dirs, then start; use for DAILY START."
	@echo "env       : Create srcs/.env (copy from ~/inception_srcs/.env or seed example); run once per VM."
	@echo "data      : Create /home/akurmyza/data/{mariadb,wordpress}; run if folders missing."
	@echo "up        : Compose up -d (no rebuild); use to START containers quickly."
	@echo "build     : Compose up -d --build; use after Dockerfile/compose CHANGES."
	@echo "down      : Compose down; use to STOP/remove containers (keep volumes)."
	@echo "clean     : Stop/remove all + prune volumes/networks + recreate data dirs; use for HARD RESET."
	@echo " ____________________________________________________________________________________________"
	@echo "ps        : Show services and ports; use to VERIFY what's running."
	@echo "net       : Show/inspect 'inception' network; use to CHECK container IPs/connectivity."
	@echo "vols      : List/inspect volumes; use to CONFIRM persistence paths."
	@echo "dbshow    : SHOW DATABASES (root); use to CONFIRM 'wordpress' DB exists."
	@echo "usershow  : List DB users/hosts (root); use to CHECK 'wpuser' grants."
	@echo "dbcheck   : Query wp_users via app user; use to PROVE WP installed + users present."
	@echo "persist   : Down then up -d; use to QUICKLY RESTART stack without rebuild."
	@echo "nginxlogs : Tail nginx logs; use to DEBUG HTTPS/proxy issues."
	@echo "wplogs    : Tail wordpress (php-fpm) logs; use to DEBUG PHP/WP init."
	@echo "dblogs    : Tail mariadb logs; use to DEBUG DB startup/auth."
	@echo "defense   : Run ps/net/vols/dbshow/usershow/dbcheck; use during EVALUATION."


.PHONY: all env data up build down clean fresh ps net vols dbcheck dbshow usershow persist nginxlogs wplogs dblogs fixdb defense help
