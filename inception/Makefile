# ===============================
# 🌐 Inception Project – Makefile
# ===============================
# This Makefile manages the full lifecycle of your Dockerized infrastructure.
# It creates persistent folders, builds images, runs containers,
# and provides reset commands for testing persistence or fresh installs.
#
# ===============================
# 📖 HOW TO USE (Cheat sheet)
# -------------------------------
# make        → Build & run on School VM (/home/akurmyza/data)
# make mac    → Build & run on Mac (/Users/<login>/data)
# make down   → Stop containers, keep DB + WP data (persistence test ✅)
# make re     → Clean everything + rebuild (fresh install test ✅)
# make macre  → Same as "re" but for Mac
# make prune  → Extreme cleanup (wipes ALL Docker data on system ⚠️)
# ===============================

# -------------------------------
# 📂 DATA PATHS
# -------------------------------
# VM_DATA  = Path used on School VM (defense requirement)
# MAC_DATA = Path used locally on MacBook (auto-detect username)
VM_DATA  = /home/akurmyza/data
MAC_DATA = /Users/$(shell whoami)/data

# Path to docker-compose configuration
COMPOSE_FILE = srcs/docker-compose.yml

# =====================================================
# 🚀 DEFAULT TARGET (Defense in VM)
# -----------------------------------------------------
# 1) Ensures persistence folders exist in /home/akurmyza/data
# 2) Starts project with docker compose:
#    -f $(COMPOSE_FILE) → use our compose file
#    up                 → create & start containers
#    -d                 → detached (background)
#    --build            → rebuild images if Dockerfiles changed
#    --force-recreate   → always recreate containers/volumes (no prompts)
# =====================================================
all:
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
	docker compose -f $(COMPOSE_FILE) up -d --build --force-recreate
	@echo "✅ Running in VM, volumes in $(VM_DATA)"

# =====================================================
# 💻 MACBOOK TARGET (Optional for local dev)
# -----------------------------------------------------
# Same as "all" but uses /Users/<login>/data for persistence.
# USE ON MAC:
# make mac
# make macre
# =====================================================
mac:
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
	docker compose -f $(COMPOSE_FILE) up -d --build --force-recreate
	@echo "✅ Running on Mac, volumes in $(MAC_DATA)"

# =====================================================
# ⏹ DOWN TARGET
# -----------------------------------------------------
# docker compose down
# - Stops containers
# - Removes networks
# - Keeps volumes (DB + WP data persists ✅)
# Use this to test persistence between restarts.
# =====================================================
down:
	docker compose -f $(COMPOSE_FILE) down

# =====================================================
# 🧹 CLEAN TARGET
# -----------------------------------------------------
# Project reset for defense:
# - Stops all containers
# - Removes containers, images, volumes, and networks
# - Data is lost ⚠️
#
# Commands explained:
# docker stop $$(docker ps -qa)  → stop all containers
# docker rm -f $$(docker ps -qa) → remove all containers
# docker rmi -f $$(docker images -qa) → remove all images
# docker volume rm $$(docker volume ls -q) → delete all volumes
# docker network rm $$(docker network ls -q) → delete all networks
# =====================================================
clean:
	docker stop $$(docker ps -qa) || true
	docker rm -f $$(docker ps -qa) || true
	docker rmi -f $$(docker images -qa) || true
	docker volume rm $$(docker volume ls -q) || true
	docker network rm $$(docker network ls -q) 2>/dev/null || true

# =====================================================
# 🔄 REBUILD TARGETS
# -----------------------------------------------------
# re    = Clean + fresh rebuild (for School VM, defense use)
# macre = Clean + fresh rebuild (for MacBook dev)
# =====================================================
re: clean all
macre: clean mac

# =====================================================
# 🔥 PRUNE TARGET
# -----------------------------------------------------
# Extreme cleanup of ALL Docker data (not only Inception):
# docker system prune -af --volumes
# -a        → remove ALL unused images
# -f        → force (no confirmation)
# --volumes → also delete unused volumes
# ⚠️ Be careful: this wipes unrelated projects too!
# =====================================================
prune:
	docker system prune -af --volumes

.PHONY: all mac down clean re macre prune
