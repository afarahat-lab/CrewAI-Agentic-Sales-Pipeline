import os
import sys

from crewai.llm import LLM

from .env import get_openai_api_key


DEFAULT_OPENAI_MODEL = os.getenv("OPENAI_MODEL_NAME", "gpt-5.2")
DEFAULT_OLLAMA_MODEL = os.getenv("OLLAMA_MODEL_NAME", "ollama/llama3")
DEFAULT_OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://192.168.68.68:11434")


def select_provider() -> str:
    configured_provider = os.getenv("LLM_PROVIDER", "").strip().lower()
    if configured_provider in {"openai", "ollama"}:
        return configured_provider

    if not sys.stdin.isatty():
        return "openai"

    print("Select the LLM provider:")
    print("1. OpenAI")
    print(f"2. Ollama ({DEFAULT_OLLAMA_BASE_URL})")

    while True:
        choice = input("Enter 1 or 2: ").strip().lower()
        if choice in {"1", "openai"}:
            return "openai"
        if choice in {"2", "ollama"}:
            return "ollama"
        print("Invalid selection. Enter 1 for OpenAI or 2 for Ollama.")


def build_llm(provider: str) -> LLM:
    if provider == "openai":
        api_key = get_openai_api_key()
        os.environ.pop("OPENAI_API_BASE", None)
        os.environ.pop("OPENAI_BASE_URL", None)
        return LLM(model=DEFAULT_OPENAI_MODEL, api_key=api_key)

    if provider != "ollama":
        raise ValueError(f"Unsupported provider: {provider}")

    ollama_api_key = os.getenv("OLLAMA_API_KEY", "ollama")
    # os.environ["OPENAI_API_KEY"] = ollama_api_key
    # os.environ["OPENAI_API_BASE"] = DEFAULT_OLLAMA_BASE_URL
    # os.environ["OPENAI_BASE_URL"] = DEFAULT_OLLAMA_BASE_URL
    return LLM(
        model=DEFAULT_OLLAMA_MODEL,
        base_url=DEFAULT_OLLAMA_BASE_URL,
        api_key=ollama_api_key,
    )


def build_llm_from_selection() -> LLM:
    return build_llm(select_provider())