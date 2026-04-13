# --------------------------------------------------
# Base image
# --------------------------------------------------
# Lightweight Python image → faster builds, smaller size
FROM python:3.11-slim

# --------------------------------------------------
# Working directory
# --------------------------------------------------
# All commands will run from /app inside the container
WORKDIR /app

# --------------------------------------------------
# Python runtime settings
# --------------------------------------------------
# Avoid creating .pyc files (not useful in containers)
ENV PYTHONDONTWRITEBYTECODE=1

# Ensure logs are flushed immediately (important for Cloud Run)
ENV PYTHONUNBUFFERED=1

# --------------------------------------------------
# Install uv (fast Python package manager)
# --------------------------------------------------
# Copy uv binary directly from official image (faster than pip install)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# --------------------------------------------------
# Install dependencies (optimized for Docker cache)
# --------------------------------------------------
# Copy only dependency files first
# → this layer is cached if dependencies don’t change
COPY pyproject.toml uv.lock ./

# Tell uv to install packages into the system Python environment
# (/usr/local is the default Python prefix in this image)
ENV UV_PROJECT_ENVIRONMENT=/usr/local

# Install dependencies (without dev tools)
# --no-install-project → avoid installing local code at this stage (better cache)
RUN uv sync --frozen --no-dev --no-install-project

# --------------------------------------------------
# Copy application code
# --------------------------------------------------
# Done after dependencies to maximize cache efficiency
COPY app ./app

# --------------------------------------------------
# Runtime configuration
# --------------------------------------------------
# Cloud Run injects PORT dynamically, but we set a default
ENV PORT=8080

# --------------------------------------------------
# Start the application
# --------------------------------------------------
# Use uv run:
# - ensures environment is correctly used
# - --no-sync avoids re-installing dependencies at runtime
CMD ["sh", "-c", "uv run --no-sync uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]