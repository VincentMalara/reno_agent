from fastapi import APIRouter

# Router dedicated to health checks
# Used by Cloud Run / monitoring systems to verify the service is up
router = APIRouter(prefix="/health", tags=["health"])


# Simple healthcheck endpoint
#
# Purpose:
# - allow Cloud Run to check container readiness
# - enable uptime monitoring
# - provide a quick sanity check for the API
@router.get("")
async def healthcheck() -> dict[str, str]:
    return {"status": "ok"}
