from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Provider: "vertex" or "gemini"
    llm_provider: str = "vertex"

    # Example:
    # - Vertex AI: "vertex_ai/gemini-2.5-flash-lite"
    # - AI Studio: "gemini/gemini-2.5-flash-lite"
    llm_model: str = "vertex_ai/gemini-2.5-flash-lite"

    # Google AI Studio only
    gemini_api_key: str | None = None

    # Vertex AI only
    vertex_project: str | None = None
    vertex_location: str = "europe-west1"

    log_level: str = "INFO"

    class Config:
        env_file = ".env"


settings = Settings()
