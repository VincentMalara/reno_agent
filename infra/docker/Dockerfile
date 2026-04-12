# --------------------------------------------------
# Base image
# --------------------------------------------------
FROM python:3.11-slim

# --------------------------------------------------
# Working directory
# --------------------------------------------------
WORKDIR /app

# --------------------------------------------------
# Python runtime settings
# --------------------------------------------------
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# --------------------------------------------------
# Install uv
# --------------------------------------------------
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# --------------------------------------------------
# Install dependencies
# --------------------------------------------------
COPY pyproject.toml uv.lock ./

# Install project dependencies into the system environment
# instead of a local virtualenv
RUN uv sync --frozen --no-dev --no-install-project --system

# --------------------------------------------------
# Copy application code
# --------------------------------------------------
COPY app ./app

# If you need README or other runtime files, copy them explicitly
# COPY README.md ./

# Install the project itself if needed
RUN uv pip install --system .

# --------------------------------------------------
# Runtime configuration
# --------------------------------------------------
ENV PORT=8080

# --------------------------------------------------
# Start the application
# --------------------------------------------------
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]