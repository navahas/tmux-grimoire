#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux bind-key f if-shell -F "#{==:#{client_session},_buoyshell-manager}" \
    "detach-client" \
    "run-shell '$CURRENT_DIR/scripts/buoy.sh'"
