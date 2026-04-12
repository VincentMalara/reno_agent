"""
Main application entrypoint.

This file is responsible for:
- creating the FastAPI app
- mounting versioned API routers
- exposing the HTTP interface

Business logic, LLM orchestration, and domain rules
are intentionally kept outside of this layer.
"""

from fastapi import FastAPI

# Import the versioned API router (v1)
# This router aggregates all endpoints for version 1 of the API
from app.api.v1.router import api_router

# Create the FastAPI application instance
# The title is used in the OpenAPI / Swagger UI documentation
app = FastAPI(title="Reno Agent API")


# Mount the v1 API under the /api/v1 prefix
# This allows us to version the API from the start.
#
# Why versioning?
# - Prevent breaking changes for existing clients
# - Allow iterative improvements (LLM outputs, schemas, pricing logic)
# - Support multiple API versions in parallel (e.g., /api/v1, /api/v2)
#
# Example endpoints:
# - POST /api/v1/chat
# - GET  /api/v1/health
#
# Future:
# app.include_router(api_v2_router, prefix="/api/v2")
app.include_router(api_router, prefix="/api/v1")
