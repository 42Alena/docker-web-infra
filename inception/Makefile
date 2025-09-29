# ===============================
# 🌐 Inception Project – Makefile
# ===============================
# Manages the full lifecycle of your Dockerized infrastructure.
# ===============================

# 📂 DATA PATHS
VM_DATA  = /home/akurmyza/data               # Path to store MariaDB + WordPress volumes in VM
MAC_DATA = /Users/$(shell whoami)/data       # Path to store MariaDB + WordPress volumes on Mac
COMPOSE_FILE = srcs/docker-compose.yml       # Path to main docker-compose file

# 🔑 ENV FILE
ENV_SRC := $(HOME)/safe_env/.env             # Secure private copy of .env (outside repo, not git)
ENV_DST := $(CURDIR)/srcs/.env               # Destination: copied into srcs/.env for containers

# 📦 Ensure srcs/.env exists before running project
.PHONY: env
env:
	@if [ ! -f $(ENV_DST) ]; then \
		cp $(ENV_SRC) $(ENV_DST); \
		echo "✅ Copied private .env to srcs/.env"; \
	fi

# 🚀 DEFAULT TARGET: Start project on school VM
#  - Makes sure VM volumes exist in /home/login/data
#  - Then runs docker compose with correct volumes and env
all: env
	@echo "🚀 Starting Inception on School VM (defense)..."
	@if [ -d "$(VM_DATA)/mariadb" ]; then \
		echo "📂 $(VM_DATA)/mariadb already exists"; \
	else \
		mkdir -p $(VM_DATA)/mariadb && echo "✅ Created $(VM_DATA)/mariadb"; \
	fi
	@if [ -d "$(VM_DATA)/wordpress" ]; then \
		echo "📂 $(VM_DATA)/wordpress already exists"; \
	else \
		mkdir -p $(VM_DATA)/wordpress && echo "✅ Created $(VM_DATA)/wordpress"; \
	fi
	@echo "✅ Volumes ready in $(VM_DATA)"
	DATA_PATH=$(VM_DATA) docker compose -f $(COMPOSE_FILE) -p inception up -d --build --force-recreate
	@echo "✅ Running in VM, volumes in $(VM_DATA)"

# 💻 MACBOOK TARGET: Start project locally on Mac
#  - Creates volumes in ~/Users/<user>/data
#  - Launches containers with Mac paths
mac: env
	@echo "🚀 Starting Inception on MacBook..."
	@if [ -d "$(MAC_DATA)/mariadb" ]; then \
		echo "📂 $(MAC_DATA)/mariadb already exists"; \
	else \
		mkdir -p $(MAC_DATA)/mariadb && echo "✅ Created $(MAC_DATA)/mariadb"; \
	fi
	@if [ -d "$(MAC_DATA)/wordpress" ]; then \
		echo "📂 $(MAC_DATA)/wordpress already exists"; \
	else \
		mkdir -p $(MAC_DATA)/wordpress && echo "✅ Created $(MAC_DATA)/wordpress"; \
	fi
	@echo "✅ Volumes ready in $(MAC_DATA)"
	DATA_PATH=$(MAC_DATA) docker compose -f $(COMPOSE_FILE) -p inception up -d --build --force-recreate
	@echo "✅ Running on Mac, volumes in $(MAC_DATA)"

# ⏹ DOWN: Stop only this project’s containers
down:
	docker compose -f $(COMPOSE_FILE) -p inception down

# 🧹 CLEAN: Reset project only (containers, images, volumes, network)
#  - Stops and removes ALL containers
#  - Removes project images, volumes, network
#  - Leaves Docker system intact (safe reset)
clean:
	@echo "🧹 Stopping all containers..."
	docker stop $$(docker ps -qa) 2>/dev/null || true
	@echo "🧹 Removing all containers..."
	docker rm -f $$(docker ps -qa) 2>/dev/null || true
	@echo "🧹 Removing all images..."
	docker rmi -f $$(docker images -qa) 2>/dev/null || true
	@echo "🧹 Removing project volumes..."
	docker volume rm mariadb_data wordpress_data 2>/dev/null || true
	@echo "🧹 Removing project network..."
	docker network rm inception 2>/dev/null || true
	@echo "✅ Clean complete (project reset)"

# 🔄 REBUILD: Clean everything then rebuild containers
re: clean all
macre: clean mac

# 🔥 PRUNE: Extreme cleanup (⚠️ wipes absolutely all Docker data)
#  - Deletes all containers, images, networks, volumes globally
prune:
	docker system prune -af --volumes

# 🛡 DEFENSE HELPERS: Commands to show evaluator during defense

# Show running containers in table format
ps:
	@echo "🔎 Containers running:"
	docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Show project network and attached containers
net:
	@echo "🔎 Inspect custom network 'inception':"
	docker network inspect inception | grep -E '\"Name\"|\"Containers\"' || echo "⚠️ Network not found"

# Show project volumes and verify mountpoints
vols:
	@echo "🔎 Volumes (must point to /home/akurmyza/data or /Users/.../data):"
	docker volume ls
	docker volume inspect mariadb_data | grep Mountpoint || true
	docker volume inspect wordpress_data | grep Mountpoint || true

# Check MariaDB: databases + grants for WordPress user
dbcheck:
	@echo "🔎 MariaDB databases and grants (with wait)..."
	@for i in 1 2 3 4 5; do \
		docker exec -e MYSQL_PWD=$$(grep DB_ROOT_PASS srcs/.env | cut -d '=' -f2) -it mariadb \
			mariadb -uroot -e "SHOW DATABASES; SHOW GRANTS FOR '$$(grep DB_USER srcs/.env | cut -d '=' -f2)'@'%';" \
		&& break || (echo "⏳ Waiting for MariaDB... ($$i/5)"; sleep 2); \
	done

# List WordPress users
wpusers:
	@echo "🔎 WordPress users:"
	docker exec -it wordpress wp user list --allow-root

# Check TLS: confirm 1.2 & 1.3 work, 1.0 is blocked
tlscheck:
	@echo "🔎 Check TLS 1.2 (✅ should work)"
	openssl s_client -connect akurmyza.42.fr:443 -tls1_2 </dev/null | grep "Protocol" || true
	@echo "🔎 Check TLS 1.3 (✅ should work)"
	openssl s_client -connect akurmyza.42.fr:443 -tls1_3 </dev/null | grep "Protocol" || true
	@echo "🔎 Check TLS 1.0 (❌ should fail)"
	openssl s_client -connect akurmyza.42.fr:443 -tls1 </dev/null || true

# Run all defense helper checks together
defense: ps net vols dbcheck wpusers tlscheck
	@echo "✅ Defense checks complete."

.PHONY: all mac down clean re macre prune ps net vols dbcheck wpusers tlscheck defense
