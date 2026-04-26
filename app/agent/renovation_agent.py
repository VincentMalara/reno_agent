from pathlib import Path

from app.llm.client import LLMClient

PROMPT_PATH = Path(__file__).resolve().parents[1] / "prompts" / "renovation_system.md"


class RenovationAgent:
    """
    High-level agent responsible for handling renovation-related conversations.

    Responsibilities:
    - Build the prompt (system + user message)
    - Call the LLM via LLMClient
    - Encapsulate business logic (renovation assistant behavior)

    This layer is where you will later add:
    - conversation memory
    - lead extraction
    - pricing logic
    """

    def __init__(self):
        """
        Initialize the agent.

        - Instantiate the LLM client (interface to the model)
        - Load the system prompt from a file (best practice)
        """

        # LLM client (handles API calls, logging, etc.)
        self.llm = LLMClient()

        # Load system prompt from a markdown file
        # This keeps prompts versionable, readable, and editable without touching code
        self.system_prompt = PROMPT_PATH.read_text(encoding="utf-8")

    async def run(
        self,
        user_message: str,
        conversation_id: str | None = None,
    ) -> str:
        """
        Main entrypoint of the agent.

        Parameters
        ----------
        user_message : str
            Message sent by the user

        conversation_id : str | None
            Optional ID to track conversation across turns (useful for logging / future memory)

        Returns
        -------
        str
            Generated answer from the LLM
        """

        # Build the prompt sent to the LLM
        # Structure follows OpenAI-style format (compatible with LiteLLM)
        messages = [
            {
                "role": "system",
                "content": self.system_prompt,  # defines behavior, rules, tone
            },
            {
                "role": "user",
                "content": user_message,  # current user input
            },
        ]

        # Call the LLM through the client abstraction
        # conversation_id is passed for logging / observability
        return await self.llm.chat(
            messages=messages,
            conversation_id=conversation_id,
        )
