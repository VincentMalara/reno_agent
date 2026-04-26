import logging
import time

from litellm import acompletion

from app.core.config import settings

# Create a logger specific to this module
# __name__ allows hierarchical logging (useful in large apps)
logger = logging.getLogger(__name__)


class LLMClient:
    """
    Wrapper around LiteLLM to handle all LLM calls in a consistent way.

    Responsibilities:
    - Call the LLM (Gemini, Vertex AI, etc.)
    - Measure latency (performance monitoring)
    - Log success and errors (observability)
    - Abstract provider differences (Gemini API vs Vertex AI)
    """

    def __init__(self):
        """
        Initialize the client using centralized configuration.

        Using settings (Pydantic) instead of os.getenv:
        - cleaner
        - validated at startup
        - easier to maintain

        Also validates provider-specific configuration early (fail fast).
        """

        # Model to use
        # Example:
        # - gemini/gemini-2.5-flash-lite (Google AI Studio)
        # - vertex_ai/gemini-2.5-flash-lite (Vertex AI)
        self.model = settings.llm_model

        # Validate configuration depending on provider
        if settings.llm_provider == "gemini":
            # Google AI Studio requires an API key
            if not settings.gemini_api_key:
                raise ValueError("GEMINI_API_KEY is not set")

        elif settings.llm_provider == "vertex":
            # Vertex AI requires project + region (auth handled via ADC)
            if not settings.vertex_project:
                raise ValueError("VERTEX_PROJECT is not set")

        else:
            # Prevent silent misconfiguration
            raise ValueError(f"Unsupported LLM_PROVIDER: {settings.llm_provider}")

    async def chat(
        self,
        messages: list[dict],
        conversation_id: str | None = None,
    ) -> str:
        """
        Send a chat request to the LLM and return the generated response.

        Parameters
        ----------
        messages : list[dict]
            Conversation in OpenAI format:
            [
                {"role": "system", "content": "..."},
                {"role": "user", "content": "..."},
                {"role": "assistant", "content": "..."}
            ]

        conversation_id : str | None
            Optional identifier to track a conversation across multiple turns.
            Useful for logging and debugging.

        Returns
        -------
        str
            Generated response from the LLM

        Behavior
        --------
        - Dynamically adapts to provider (Gemini vs Vertex AI)
        - Measures latency of the LLM call
        - Logs success or failure
        - Raises exception if something goes wrong
        """

        # Start timer to measure latency (high precision timer)
        start_time = time.perf_counter()

        try:
            # Base parameters shared across providers
            kwargs = {
                "model": self.model,  # which model to use
                "messages": messages,  # conversation context
            }

            # Provider-specific configuration
            if settings.llm_provider == "gemini":
                # Google AI Studio → API key auth
                kwargs["api_key"] = settings.gemini_api_key

            elif settings.llm_provider == "vertex":
                # Vertex AI → project + location + ADC auth
                kwargs["vertex_project"] = settings.vertex_project
                kwargs["vertex_location"] = settings.vertex_location

            # Call the LLM asynchronously via LiteLLM
            # LiteLLM abstracts differences between providers
            response = await acompletion(**kwargs)

            # Compute latency in milliseconds
            latency_ms = round((time.perf_counter() - start_time) * 1000)

            # Log success with structured metadata
            logger.info(
                "LLM call succeeded",
                extra={
                    "provider": settings.llm_provider,
                    "model": self.model,
                    "conversation_id": conversation_id,
                    "latency_ms": latency_ms,
                },
            )

            # Extract generated text from LiteLLM response
            # Standard format: response.choices[0].message.content
            return response.choices[0].message.content

        except Exception:
            # Compute latency even in case of failure
            latency_ms = round((time.perf_counter() - start_time) * 1000)

            # Log full error stack trace
            logger.exception(
                "LLM call failed",
                extra={
                    "provider": settings.llm_provider,
                    "model": self.model,
                    "conversation_id": conversation_id,
                    "latency_ms": latency_ms,
                },
            )

            # Re-raise the exception so FastAPI (or caller) can handle it
            raise
