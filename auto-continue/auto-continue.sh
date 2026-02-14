#!/bin/bash
# Auto-Continue Orchestrator launcher for Git Bash
# Unsets env vars that prevent nested Claude sessions

unset CLAUDECODE
unset CLAUDE_CODE_ENTRYPOINT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
node "$SCRIPT_DIR/index.js" "$@"
