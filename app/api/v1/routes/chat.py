from functools import lru_cache

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.agent.renovation_agent import RenovationAgent

# Router configuration
router = APIRouter(prefix="/chat", tags=["chat"])


# -----------------------
# REQUEST / RESPONSE SCHEMAS
# -----------------------


class ChatRequest(BaseModel):
    message: str
    conversation_id: str | None = None


class ChatResponse(BaseModel):
    answer: str
    conversation_id: str | None = None


# -----------------------
# DEPENDENCY INJECTION
# -----------------------


@lru_cache
def get_agent() -> RenovationAgent:
    """
    Dependency function used by FastAPI to provide a RenovationAgent instance.

    Why use this instead of a global variable?

    - Avoids instantiating the agent at import time (prevents startup crashes)
    - Ensures configuration (.env) is loaded before instantiation
    - Makes testing easier (can override dependency)
    - Scales better (stateless / cloud-friendly)

    This function is called automatically by FastAPI when the endpoint is hit.
    """
    return RenovationAgent()


# -----------------------
# ROUTE
# -----------------------


@router.post("", response_model=ChatResponse)
async def chat(
    payload: ChatRequest,
    agent: RenovationAgent = Depends(get_agent),  # noqa: B008
) -> ChatResponse:
    """
    Chat endpoint.

    This endpoint processes a user message and returns a generated response
    from the renovation agent.

    Flow
    ----
    1. FastAPI parses and validates the request body into a ChatRequest object
    2. FastAPI resolves dependencies and injects a RenovationAgent instance
    3. The agent processes the message via the LLM (agent.run)
    4. A structured ChatResponse is returned

    Parameters
    ----------
    payload : ChatRequest
        Request payload containing:
        - message: user input text
        - conversation_id: optional identifier for conversation tracking

    agent : RenovationAgent
        Injected dependency responsible for handling the conversation logic
        and interacting with the LLM backend

    Returns
    -------
    ChatResponse
        - answer: generated response from the agent
        - conversation_id: propagated conversation identifier

    Raises
    ------
    HTTPException
        500: LLM configuration error (e.g. missing API keys, invalid setup)
        503: LLM service unavailable (e.g. provider error, timeout, upstream failure)

    Notes
    -----
    - This endpoint is stateless: conversation context must be handled externally
    - Dependency injection enables easier testing and future extensibility
    - Errors are intentionally abstracted to avoid leaking internal details
    """

    try:
        answer = await agent.run(
            user_message=payload.message,
            conversation_id=payload.conversation_id,
        )
    except ValueError as exc:
        raise HTTPException(status_code=500, detail="LLM configuration error") from exc
    except Exception as exc:
        raise HTTPException(status_code=503, detail="LLM service unavailable") from exc

    return ChatResponse(
        answer=answer,
        conversation_id=payload.conversation_id,
    )
