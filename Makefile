# --------------------------------------------------
# Default target
# --------------------------------------------------
# When running `make` without arguments, display help
.DEFAULT_GOAL := help


# --------------------------------------------------
# Environment files
# --------------------------------------------------
# Deployment configuration is stored in env files
DEV_ENV := env/dev.env
PROD_ENV := env/prod.env


# --------------------------------------------------
# HELP
# --------------------------------------------------
help:
	@echo "Available commands:"
	@echo ""
	@echo "  make install        Install dependencies (dev included)"
	@echo "  make dev            Run the API locally with auto-reload"
	@echo ""
	@echo "  make lint           Format and auto-fix code with Ruff"
	@echo "  make check          Run CI-style checks (no file changes)"
	@echo "  make test           Run tests"
	@echo ""
	@echo "  make docker-build   Build Docker image locally"
	@echo "  make docker-run     Run Docker image locally"
	@echo ""
	@echo "  make deploy-dev     Build and deploy using env/dev.env"
	@echo "  make deploy-prod    Build and deploy using env/prod.env"


# --------------------------------------------------
# INSTALL
# --------------------------------------------------
install:
	uv sync --dev


# --------------------------------------------------
# DEV
# --------------------------------------------------
# Run FastAPI locally with hot reload
dev:
	uv run uvicorn app.main:app --reload


# --------------------------------------------------
# LINT / FORMAT
# --------------------------------------------------
# Local developer command:
# - formats code
# - auto-fixes simple lint issues
lint:
	uv run ruff format .
	uv run ruff check --fix .

# CI-safe command:
# - checks formatting
# - checks linting
# - does not modify files
check:
	uv run ruff format --check .
	uv run ruff check .


# --------------------------------------------------
# TEST
# --------------------------------------------------
test:
	uv run pytest


# --------------------------------------------------
# DOCKER
# --------------------------------------------------
# Build Docker image from the production Dockerfile
docker-build:
	docker build -t reno-agent -f infra/docker/Dockerfile .

# Run the container locally on port 8080
docker-run:
	docker run -p 8080:8080 reno-agent


# --------------------------------------------------
# CLOUD RUN
# --------------------------------------------------
# Build + deploy development environment
deploy-dev:
	bash infra/scripts/deploy.sh $(DEV_ENV)

# Build + deploy production environment
deploy-prod:
	bash infra/scripts/deploy.sh $(PROD_ENV)