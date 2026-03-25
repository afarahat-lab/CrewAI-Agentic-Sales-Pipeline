import os


def get_required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise ValueError(f"{name} is not set. Add it to your environment or .env file.")
    return value


def get_openai_api_key() -> str:
    return get_required_env("OPENAI_API_KEY")