.PHONY: build up down restart logs clean help frontend backend

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE = docker compose

# Build the Docker images
build:
	$(COMPOSE) build

# Build only the backend
backend:
	$(COMPOSE) build backend

# Build only the frontend
frontend:
	$(COMPOSE) build frontend

# Start containers in detached mode
up:
	$(COMPOSE) up -d

ps:
	$(COMPOSE) ps

# Start only the backend in detached mode
up-backend:
	$(COMPOSE) up -d backend

# Start only the frontend in detached mode
up-frontend:
	$(COMPOSE) up -d frontend

# Start containers and view logs
up-logs:
	$(COMPOSE) up

# Stop and remove containers
down:
	$(COMPOSE) down

# Restart containers
restart: down up

# Restart only backend
restart-backend: 
	$(COMPOSE) stop backend
	$(COMPOSE) rm -f backend
	$(COMPOSE) up -d backend

# Restart only frontend
restart-frontend:
	$(COMPOSE) stop frontend
	$(COMPOSE) rm -f frontend
	$(COMPOSE) up -d frontend

# View logs
logs:
	$(COMPOSE) logs -f

# View logs for backend only
logs-backend:
	$(COMPOSE) logs -f backend

# View logs for frontend only
logs-frontend:
	$(COMPOSE) logs -f frontend

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
	@echo "make build       - Build all Docker images"
	@echo "make backend     - Build only the backend Docker image"
	@echo "make frontend    - Build only the frontend Docker image"
	@echo "make up          - Start all containers in detached mode"
	@echo "make up-backend  - Start only the backend container"
	@echo "make up-frontend - Start only the frontend container"
	@echo "make up-logs     - Start containers and view logs"
	@echo "make down        - Stop and remove containers"
	@echo "make restart     - Restart all containers"
	@echo "make restart-backend  - Restart only the backend container"
	@echo "make restart-frontend - Restart only the frontend container"
	@echo "make logs        - View all container logs"
	@echo "make logs-backend     - View only backend logs"
	@echo "make logs-frontend    - View only frontend logs"
	@echo "make clean       - Remove stopped containers, networks, volumes, images"
	@echo "make rebuild     - Full rebuild and restart of containers"
	@echo "make help        - Show this help message"
