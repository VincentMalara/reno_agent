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
	@echo "  make install         Install dependencies"
	@echo "  make dev             Run API locally"
	@echo ""
	@echo "  make lint            Format & fix code"
	@echo "  make check           CI checks (no changes)"
	@echo "  make test            Run tests"
	@echo ""
	@echo "  make docker-build    Build Docker image"
	@echo "  make docker-run      Run Docker locally"
	@echo ""
	@echo "  make setup-iam-dev   Setup IAM (dev)"
	@echo "  make setup-iam-prod  Setup IAM (prod)"
	@echo ""
	@echo "  make deploy-dev      Deploy dev"
	@echo "  make deploy-prod     Deploy prod"
	@echo ""
	@echo "  make chat-dev        Test chat (dev)"
	@echo "  make chat-prod       Test chat (prod)"
	@echo "  make chat-dev-debug  Test chat (debug)"
	@echo ""
	@echo "  make health-dev      Health check (dev)"
	@echo "  make health-prod     Health check (prod)"


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
	docker build -t reno-agent -f Dockerfile .

# Run the container locally on port 8080
docker-run:
	docker run -p 8080:8080 reno-agent

# --------------------------------------------------
# IAM SETUP
# --------------------------------------------------
setup-iam-dev:
	bash infra/scripts/setup_iam.sh $(DEV_ENV)

setup-iam-prod:
	bash infra/scripts/setup_iam.sh $(PROD_ENV)


# --------------------------------------------------
# DEPLOYMENT
# --------------------------------------------------
# Build + deploy development environment
deploy-dev:
	bash infra/scripts/deploy.sh $(DEV_ENV)

# Build + deploy production environment
deploy-prod:
	bash infra/scripts/deploy.sh $(PROD_ENV)


# --------------------------------------------------
# TEST DEPLOYMENT
# --------------------------------------------------
# --------------------------------------------------
# HEALTH CHECKS
# --------------------------------------------------

health-dev:
	@set -a && . $(DEV_ENV) && set +a && \
	URL=$$(gcloud run services describe $$SERVICE_NAME \
		--project=$$PROJECT_ID \
		--region=$$REGION \
		--format='value(status.url)') && \
	echo "Checking $$URL/api/v1/health" && \
	curl -sf $$URL/api/v1/health | jq

health-prod:
	@set -a && . $(PROD_ENV) && set +a && \
	URL=$$(gcloud run services describe $$SERVICE_NAME \
		--project=$$PROJECT_ID \
		--region=$$REGION \
		--format='value(status.url)') && \
	echo "Checking $$URL/api/v1/health" && \
	curl -sf $$URL/api/v1/health | jq


# --------------------------------------------------
# CHAT TESTS
# --------------------------------------------------

chat-dev:
	@set -a && . $(DEV_ENV) && set +a && \
	URL=$$(gcloud run services describe $$SERVICE_NAME \
		--project=$$PROJECT_ID \
		--region=$$REGION \
		--format='value(status.url)') && \
	echo "Testing chat (dev) on $$URL" && \
	curl -sf -X POST $$URL/api/v1/chat \
		-H "Content-Type: application/json" \
		-d '{"message":"Je veux refaire ma salle de bain"}' | jq

chat-prod:
	@set -a && . $(PROD_ENV) && set +a && \
	URL=$$(gcloud run services describe $$SERVICE_NAME \
		--project=$$PROJECT_ID \
		--region=$$REGION \
		--format='value(status.url)') && \
	echo "Testing chat (prod) on $$URL" && \
	curl -sf -X POST $$URL/api/v1/chat \
		-H "Content-Type: application/json" \
		-d '{"message":"Je veux refaire ma salle de bain"}' | jq

chat-dev-debug:
	@set -a && . $(DEV_ENV) && set +a && \
	URL=$$(gcloud run services describe $$SERVICE_NAME \
		--project=$$PROJECT_ID \
		--region=$$REGION \
		--format='value(status.url)') && \
	echo "Testing chat (debug) on $$URL" && \
	curl -i -X POST $$URL/api/v1/chat \
		-H "Content-Type: application/json" \
		-d '{"message":"Je veux refaire ma salle de bain"}'