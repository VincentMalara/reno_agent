from collections.abc import Iterator
from contextlib import contextmanager

from fastapi.testclient import TestClient

from app.api.v1.routes.chat import get_agent
from app.main import app


class FakeAgent:
    """Test double that simulates a successful agent response without calling the LLM."""

    async def run(self, user_message: str, conversation_id: str | None = None) -> str:
        return "Mocked answer"


class FailingAgent:
    """Test double that simulates an upstream provider failure."""

    async def run(self, user_message: str, conversation_id: str | None = None) -> str:
        raise RuntimeError("provider down")


@contextmanager
def override_agent(agent: object) -> Iterator[None]:
    """
    Temporarily replace FastAPI's agent dependency for one test.

    This keeps the route test focused on HTTP behavior and avoids requiring
    real LLM credentials, network access, or provider availability.
    """
    app.dependency_overrides[get_agent] = lambda: agent
    try:
        yield
    finally:
        app.dependency_overrides.pop(get_agent, None)


def test_chat_returns_agent_answer() -> None:
    # The fake agent lets us verify the route contract without a real LLM call.
    with override_agent(FakeAgent()), TestClient(app) as client:
        response = client.post(
            "/api/v1/chat",
            json={
                "message": "How much does a bathroom renovation cost?",
                "conversation_id": "conv-123",
            },
        )

    assert response.status_code == 200
    assert response.json() == {
        "answer": "Mocked answer",
        "conversation_id": "conv-123",
    }


def test_chat_returns_503_when_agent_fails() -> None:
    # Runtime failures from the agent should become a stable API error response.
    with override_agent(FailingAgent()), TestClient(app) as client:
        response = client.post(
            "/api/v1/chat",
            json={
                "message": "How much does a bathroom renovation cost?",
                "conversation_id": "conv-123",
            },
        )

    assert response.status_code == 503
    assert response.json() == {"detail": "LLM service unavailable"}
