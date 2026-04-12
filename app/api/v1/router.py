"""
API v1 router.

This module aggregates all route handlers for version 1 of the API.

Design choices:
- Routes are split by domain (chat, leads, health)
- Each domain exposes its own APIRouter
- This file composes them into a single versioned API

This structure makes it easy to:
- add/remove features
- version the API (v2, v3, ...)
- keep a clean separation of concerns
"""

from fastapi import APIRouter

# Import individual route modules
# Each module defines its own APIRouter with a specific responsibility
from app.api.v1.routes.chat import router as chat_router
from app.api.v1.routes.health import router as health_router
from app.api.v1.routes.leads import router as leads_router

# Main router for API v1
# This acts as an aggregator for all version 1 endpoints
api_router = APIRouter()


# Register route modules
# Each router is responsible for a specific domain:
#
# - health: service healthcheck (used for monitoring / Cloud Run readiness)
# - chat: main entrypoint for the LLM agent (user interactions)
# - leads: lead extraction and management
#
# This separation keeps concerns isolated and makes the API easier to scale and maintain
api_router.include_router(health_router)
api_router.include_router(chat_router)
api_router.include_router(leads_router)
