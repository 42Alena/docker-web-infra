# ===============================
# Inception Project – Makefile
# ===============================
# This Makefile builds and runs your Docker infrastructure (NGINX, MariaDB, WordPress).
# It supports three environments:
#   - mac    : MacBook (local dev)
#   - vm     : School VM (VirtualBox Debian)
#   - school : School bare-metal computer (sgoinfre)
#
# ===============================
# 📖 HOW TO USE
# make mac      -> Run project on your MacBook
# make vm       -> Run project inside Virtual Machine (defense!)
# make school   -> Run project directly on school computers
# make down     -> Stop containers but KEEP data
# make clean    -> Remove containers, images, volumes (⚠ data lost)
# make prune    -> Extreme cleanup (⚠ wipes ALL docker resources on machine)
# make eval     -> Minimal version for evaluation (inside VM only)
# ===============================

# Paths for persistent volumes depending on environment
MAC_DATA    = /Users/$(USER)/data        # expands to your Mac login
VM_DATA     = /home/akurmyza/data        # school VM always uses akurmyza
SCHOOL_DATA = /goinfre/akurmyza/data     # sgoinfre = temporary storage at school

# Default docker-compose file
COMPOSE_FILE = srcs/docker-compose.yml

# -------------------------------
#  Helper: create directories
# -------------------------------
# We must always have "data/mariadb" and "data/wordpress" existing,
# otherwise Docker volumes will not bind correctly.
define create_dirs
	@mkdir -p $(1)/mariadb   # mkdir = make directory
	@mkdir -p $(1)/wordpress # -p = no error if exists, also create parent dirs
endef

# -------------------------------
#  Targets per environment
# -------------------------------

## Run on MacBook (folders in /Users/username/data)
mac:
	@echo "🚀 Starting Inception on MacBook..."
	# Create persistence folders for DB and WP inside /Users/<username>/data
	$(call create_dirs,$(MAC_DATA))
	# Run docker-compose:
	#   -f $(COMPOSE_FILE) → choose the compose file
	#   up                 → start containers
	#   -d                 → detached mode (runs in background)
	#   --build            → force rebuild of images if Dockerfile changed
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ Running on Mac, volumes in $(MAC_DATA)"

## Run inside School VM (folders in /home/akurmyza/data)
vm:
	@echo "🚀 Starting Inception on School VM..."
	# Create persistence folders inside /home/akurmyza/data
	$(call create_dirs,$(VM_DATA))
	# Run docker compose just like on Mac
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ Running on VM, volumes in $(VM_DATA)"

## Run on School bare-metal computers (sgoinfre)
school:
	@echo "🚀 Starting Inception on School Computer..."
	# Create persistence folders inside sgoinfre (not permanent!)
	$(call create_dirs,$(SCHOOL_DATA))
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ Running on school computer, volumes in $(SCHOOL_DATA)"

# -------------------------------
#  Utility commands
# -------------------------------

## Stop containers but keep images and volumes
down:
	# docker compose down = stop + remove containers, but keep volumes
	docker compose -f $(COMPOSE_FILE) down

## Full clean: remove containers, images, volumes, networks
clean:
	# Stop all running containers
	docker stop $$(docker ps -qa) || true
	# Remove all containers (-f = force)
	docker rm -f $$(docker ps -qa) || true
	# Remove all images (-f = force)
	docker rmi -f $$(docker images -qa) || true
	# Remove all volumes
	docker volume rm $$(docker volume ls -q) || true
	# Remove all networks (ignore errors if none)
	docker network rm $$(docker network ls -q) 2>/dev/null || true

## EXTREME cleanup: remove absolutely everything (⚠ dangerous!)
prune:
	# docker system prune = remove unused data
	# -a        = remove ALL unused images (not just dangling)
	# -f        = force, skip confirmation prompt
	# --volumes = also remove all unused volumes
	docker system prune -af --volumes



# =====================================================
#  ⚠️ EVALUATION VERSION (School VM only)
# =====================================================
# This section is the MINIMAL version required by the subject.
# It uses your 42 login (akurmyza) and hardcodes the correct paths.
# During defense, run only these targets inside the School VM.
# =====================================================

# Path for persistence inside School VM (must match subject rules)
EVAL_DATA = /home/akurmyza/data
EVAL_COMPOSE = srcs/docker-compose.yml

## Start project in School VM
eval:
	@echo "🚀 Evaluation start (VM only)..."
	# Create the persistence folders required by subject:
	# - /home/akurmyza/data/mariadb
	# - /home/akurmyza/data/wordpress
	mkdir -p $(EVAL_DATA)/mariadb
	mkdir -p $(EVAL_DATA)/wordpress
	# Run docker compose:
	# -f $(EVAL_COMPOSE) → specify compose file
	# up → start services
	# -d → detached (run in background)
	# --build → rebuild images before starting
	docker compose -f $(EVAL_COMPOSE) up -d --build
	@echo "✅ Containers running in VM with volumes in $(EVAL_DATA)"

## Stop containers but keep data (volumes stay)
eval-down:
	# docker compose down removes containers, but volumes remain
	docker compose -f $(EVAL_COMPOSE) down

## Full clean (as evaluation sheet requires before defense)
eval-clean:
	# Stop all running containers
	docker stop $$(docker ps -qa) || true
	# Remove all containers
	docker rm -f $$(docker ps -qa) || true
	# Remove all images
	docker rmi -f $$(docker images -qa) || true
	# Remove all volumes
	docker volume rm $$(docker volume ls -q) || true
	# Remove all networks
	docker network rm $$(docker network ls -q) 2>/dev/null || true





#_______________________FOR INTRA___________________________-

# # ===============================
# # Inception Project – Evaluation Makefile (VM only)
# # ===============================
# # This Makefile is the minimal version required by the subject.
# # It runs inside the School VM, using hardcoded path /home/akurmyza/data.
# #
# # Usage:
# #   make        -> Start project
# #   make down   -> Stop containers (keep data)
# #   make clean  -> Full reset (containers, images, volumes, networks)
# # ===============================

# COMPOSE_FILE = srcs/docker-compose.yml
# DATA_PATH    = /home/akurmyza/data

# # Default target → start project
# all:
# 	@echo " Starting Inception (evaluation VM)..."
# 	mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
# 	docker compose -f $(COMPOSE_FILE) up -d --build
# 	@echo " Containers running with volumes in $(DATA_PATH)"

# # Stop containers but keep volumes (data persists)
# down:
# 	docker compose -f $(COMPOSE_FILE) down

# # Full reset: remove containers, images, volumes, networks
# clean:
# 	docker stop $$(docker ps -qa) || true
# 	docker rm -f $$(docker ps -qa) || true
# 	docker rmi -f $$(docker images -qa) || true
# 	docker volume rm $$(docker volume ls -q) || true
# 	docker network rm $$(docker network ls -q) 2>/dev/null || true
