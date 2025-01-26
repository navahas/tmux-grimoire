#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/scripts/helpers.sh"

# Set default key binding using the MANAGER_SESSION from config
tmux bind-key f if-shell -F "#{==:#{client_session},$MANAGER_SESSION}" \
    "detach-client" \
    "run-shell '$CURRENT_DIR/scripts/popup.sh'"
