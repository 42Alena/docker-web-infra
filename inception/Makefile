# ===============================
# Inception Project – Makefile
# ===============================
# Default target runs in School VM / School computers (/home/akurmyza/data).
# Optional "mac" target for MacBook (/Users/<mac-login>/data).
#
# ===============================
# 📖 HOW TO USE
# make        -> Start project in School VM (defense path /home/akurmyza/data)
# make mac    -> Start project on MacBook (/Users/<your-mac-login>/data)
# make down   -> Stop containers but keep persistence
# make clean  -> Full reset (containers, images, volumes, networks)
# make prune  -> Extreme cleanup (wipes all Docker data on the system)
# ===============================

# Paths for persistent data
VM_DATA  = /home/akurmyza/data     # REQUIRED path for defense (subject rule)
MAC_DATA = /Users/$(USER)/data     # Normal path on macOS

# Path to docker-compose configuration
COMPOSE_FILE = srcs/docker-compose.yml

# -------------------------------
# Helper function: create folders
# -------------------------------
# Docker needs the persistence folders to exist on the host machine.
#   - mariadb   : stores MariaDB database files
#   - wordpress : stores WordPress site files
# If they don’t exist, Docker won’t mount volumes correctly.
define create_dirs
	@mkdir -p $(1)/mariadb   # -p = no error if exists, create parents if needed
	@mkdir -p $(1)/wordpress
endef

# =====================================================
# 🚀 DEFAULT TARGET (Defense in VM)
# -----------------------------------------------------
# Runs project inside School VM or school computers.
# Creates persistence folders in /home/akurmyza/data
# and starts all containers with docker compose.
# =====================================================
all:
	@echo "🚀 Starting Inception on School VM (defense)..."
	$(call create_dirs,$(VM_DATA))
	# Run docker compose:
	# -f $(COMPOSE_FILE) → use our compose file
	# up                  → create & start containers
	# -d                  → detached (background mode)
	# --build             → rebuild images if Dockerfiles changed
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ Running in VM, volumes in $(VM_DATA)"

# =====================================================
# 💻 MACBOOK TARGET (Optional for local dev)
# -----------------------------------------------------
# Same as VM target but uses /Users/<mac-login>/data
# =====================================================
mac:
	@echo "🚀 Starting Inception on MacBook..."
	$(call create_dirs,$(MAC_DATA))
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ Running on Mac, volumes in $(MAC_DATA)"

# =====================================================
# ⏹ DOWN TARGET
# -----------------------------------------------------
# Stops and removes containers + networks
# BUT keeps volumes (WordPress + DB data persists).
# =====================================================
down:
	docker compose -f $(COMPOSE_FILE) down

# =====================================================
# 🧹 CLEAN TARGET
# -----------------------------------------------------
# Full reset → removes EVERYTHING:
#   - Containers (running + stopped)
#   - Images (forces rebuild next run)
#   - Volumes (⚠ deletes DB + WP data)
#   - Networks
#
# Use before defense or when you need a fresh start.
# =====================================================
clean:
	# Stop all running containers
	docker stop $$(docker ps -qa) || true
	# Remove all containers
	docker rm -f $$(docker ps -qa) || true
	# Remove all images
	docker rmi -f $$(docker images -qa) || true
	# Remove all volumes (⚠ data lost)
	docker volume rm $$(docker volume ls -q) || true
	# Remove all networks
	docker network rm $$(docker network ls -q) 2>/dev/null || true

# =====================================================
# 🔥 PRUNE TARGET (Extreme cleanup)
# -----------------------------------------------------
# Deletes ALL Docker data on the machine:
#   - Unused containers
#   - Unused images
#   - Unused networks
#   - Unused volumes
#
# ⚠ Use with caution: wipes even unrelated projects.
# =====================================================
prune:
	docker system prune -af --volumes

