#!/bin/bash
# vim: set ft=bash ts=2 sw=2 sts=2 et ai si sta:

# MCP Memory Service wrapper
#
# Install (reproducible) on a new machine:
#   brew install python@3.14
#   mkdir -p ~/.local/share/mcp-memory-service
#   /opt/homebrew/opt/python@3.14/bin/python3.14 -m venv ~/.local/share/mcp-memory-service/.venv
#   source ~/.local/share/mcp-memory-service/.venv/bin/activate
#   pip install -U pip
#   pip install mcp-memory-service
#   pip install onnxruntime
#
# Latest from Git (editable):
#   git clone https://github.com/doobidoo/mcp-memory-service.git ~/.local/share/mcp-memory-service/src
#   ~/.local/share/mcp-memory-service/.venv/bin/pip install -e ~/.local/share/mcp-memory-service/src
#
# Test:
#   ~/.local/share/mcp-memory-service/.venv/bin/python -c "import sqlite3; sqlite3.connect(':memory:').enable_load_extension(True); print('sqlite loadable extensions OK')"
#   ~/.local/share/mcp-memory-service/.venv/bin/memory --help
#
# Notes:
# - If you are on Intel macOS, replace /opt/homebrew with /usr/local.
# - Editable install uses the repo at ~/.local/share/mcp-memory-service/src.
# - This wrapper expects the venv at ~/.local/share/mcp-memory-service/.venv.

export MCP_MEMORY_BASE_DIR="${HOME}/.local/share/mcp-memory-service/db"
export MCP_MEMORY_BACKUPS_PATH="${HOME}/Documents/Library/M/mcp-memory-service/backups"
export MCP_BACKUP_ENABLED=true
export MCP_BACKUP_INTERVAL=hourly
export MCP_BACKUP_MAX_COUNT=48

# export MCP_ALLOW_ANONYMOUS_ACCESS=true

MCP_MEMORY_HOME="${HOME}/.local/share/mcp-memory-service"
MCP_MEMORY_BIN="${MCP_MEMORY_HOME}/.venv/bin/memory"

if [[ -f ~/.config/erebusbat/mcp-memory-service.sh ]]; then
  source ~/.config/erebusbat/mcp-memory-service.sh
fi

if [[ ! -x "${MCP_MEMORY_BIN}" ]]; then
  printf '%s\n' "mcp-memory-service not installed at: ${MCP_MEMORY_BIN}" >&2
  printf '%s\n' "See install instructions in: ${HOME}/bin/.mcp-memory.sh" >&2
  exit 1
fi

exec "${MCP_MEMORY_BIN}" "$@"
