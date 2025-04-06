.PHONY: build up down restart logs clean help

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE = docker compose

# Build the Docker images
build:
	$(COMPOSE) build

# Start containers in detached mode
up:
	$(COMPOSE) up -d

# Start containers and view logs
up-logs:
	$(COMPOSE) up

# Stop and remove containers
down:
	$(COMPOSE) down

# Restart containers
restart: down up

# View logs
logs:
	$(COMPOSE) logs -f

# Clean up system: remove stopped containers, networks, volumes, and images
clean:
	docker system prune -f
	docker volume prune -f

# Completely rebuild and restart containers
rebuild: down
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d

# Display help information
help:
	@echo "Docker Compose Makefile Commands:"
	@echo "make build      - Build Docker images"
	@echo "make up         - Start containers in detached mode"
	@echo "make up-logs    - Start containers and view logs"
	@echo "make down       - Stop and remove containers"
	@echo "make restart    - Restart containers"
	@echo "make logs       - View container logs"
	@echo "make clean      - Remove stopped containers, networks, volumes, images"
	@echo "make rebuild    - Full rebuild and restart of containers"
	@echo "make help       - Show this help message"
