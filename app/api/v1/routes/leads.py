from fastapi import APIRouter

# TODO: replace placeholder with persisted structured leads

router = APIRouter(prefix="/leads", tags=["leads"])


@router.get("")
async def list_leads() -> dict[str, list]:
    return {"leads": []}
