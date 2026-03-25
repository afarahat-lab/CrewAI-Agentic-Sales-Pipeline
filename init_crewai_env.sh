#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$PROJECT_DIR/.venv"

log() {
  printf "[setup] %s\n" "$1"
}

fail() {
  printf "[setup][error] %s\n" "$1" >&2
  exit 1
}

ensure_python_312() {
  if command -v python3.12 >/dev/null 2>&1; then
    command -v python3.12
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        fail "python3.12 not found and Homebrew is missing. Install Homebrew or Python 3.12 manually."
      fi

      log "python3.12 not found. Installing with Homebrew..."
      brew install python@3.12

      if command -v python3.12 >/dev/null 2>&1; then
        command -v python3.12
        return 0
      fi

      if [ -x "/opt/homebrew/bin/python3.12" ]; then
        echo "/opt/homebrew/bin/python3.12"
        return 0
      fi

      if [ -x "/usr/local/bin/python3.12" ]; then
        echo "/usr/local/bin/python3.12"
        return 0
      fi

      fail "python3.12 install completed but executable was not found in PATH."
      ;;
    Linux)
      fail "python3.12 not found. Install Python 3.12 with your distro package manager, then re-run this script."
      ;;
    *)
      fail "Unsupported OS: $(uname -s). Install Python 3.12 manually, then re-run this script."
      ;;
  esac
}

create_venv() {
  local py_bin="$1"

  if [ -d "$VENV_DIR" ]; then
    log "Removing existing .venv"
    rm -rf "$VENV_DIR"
  fi

  log "Creating virtual environment with $py_bin"
  "$py_bin" -m venv "$VENV_DIR"
}

install_dependencies() {
  local py_bin="$VENV_DIR/bin/python"

  log "Upgrading pip/setuptools/wheel"
  "$py_bin" -m pip install --upgrade pip setuptools wheel

  log "Installing CrewAI + Llama/Ollama dependencies"
  "$py_bin" -m pip install \
    crewai \
    crewai_tools \
    langchain_community \
    python-dotenv \
    ipython \
    litellm \
    llama-index \
    llama-index-llms-ollama \
    llama-index-embeddings-ollama \
    rich
}

main() {
  log "Project directory: $PROJECT_DIR"
  PYTHON312_BIN="$(ensure_python_312)"
  log "Using Python: $PYTHON312_BIN"

  create_venv "$PYTHON312_BIN"
  install_dependencies

  log "Done. Activate with: source .venv/bin/activate"
  log "Run with: .venv/bin/python main.py"
}

main
