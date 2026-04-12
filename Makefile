# --------------------------------------------------
# Default target
# --------------------------------------------------
# When running `make`, show help by default
.DEFAULT_GOAL := help


# --------------------------------------------------
# HELP
# --------------------------------------------------
# Lists all available commands
help:
	@echo "Available commands:"
	@echo ""
	@echo "  make install        Install dependencies (dev included)"
	@echo "  make dev            Run the API locally with auto-reload"
	@echo ""
	@echo "  make lint           Run ruff linter (auto-fix issues)"
	@echo "  make format         Format code with ruff"
	@echo "  make check          Run lint + format check (CI style)"
	@echo ""
	@echo "  make test           Run test suite"
	@echo ""
	@echo "  make docker-build   Build Docker image"
	@echo "  make docker-run     Run container locally"


# --------------------------------------------------
# INSTALL
# --------------------------------------------------
# Install dependencies using uv (including dev tools)
install:
	uv sync --dev


# --------------------------------------------------
# DEV
# --------------------------------------------------
# Run FastAPI app with auto-reload (development mode)
dev:
	uv run uvicorn app.main:app --reload


# --------------------------------------------------
# LINT / FORMAT
# --------------------------------------------------

# Run ruff format and check (auto-fix issues when possible)
lint:
	uv run ruff format .
	uv run ruff check --fix .

# CI-style check (no modifications allowed)
check:
	uv run ruff check .
	uv run ruff format --check .


# --------------------------------------------------
# TEST
# --------------------------------------------------

# Run tests with pytest
test:
	uv run pytest


# --------------------------------------------------
# DOCKER
# --------------------------------------------------

# Build Docker image using the infra Dockerfile
docker-build:
	docker build -t reno-agent -f infra/docker/Dockerfile .

# Run container locally (simulate Cloud Run)
docker-run:
	docker run -p 8080:8080 reno-agent