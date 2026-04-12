from fastapi import APIRouter
from pydantic import BaseModel

# Router dedicated to chat interactions with the AI agent
# All endpoints in this file will be prefixed with /chat
router = APIRouter(prefix="/chat", tags=["chat"])


# Request schema for a chat interaction
# - message: user input
# - conversation_id: optional identifier to keep conversation state
class ChatRequest(BaseModel):
    message: str
    conversation_id: str | None = None


# Response schema returned by the API
# - answer: generated response (LLM output)
# - conversation_id: used to maintain continuity across turns
class ChatResponse(BaseModel):
    answer: str
    conversation_id: str | None = None


# Main chat endpoint
# This is the entrypoint for user interactions with the AI agent
#
# In a full implementation, this route will:
# - call the agent orchestrator
# - manage conversation state
# - trigger lead extraction / pricing logic
@router.post("", response_model=ChatResponse)
async def chat(payload: ChatRequest) -> ChatResponse:
    # Placeholder logic (echo response)
    # Will be replaced by LLM agent call
    return ChatResponse(
        answer=f"Received: {payload.message}",
        conversation_id=payload.conversation_id,
    )
