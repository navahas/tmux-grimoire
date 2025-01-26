#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buoy_key=$(tmux show-option -gv '@buoyshell-key')
buoy_session=$(tmux show-option -gv '@buoyshell-session')

: "${buoy_key:=f}"
: "${buoy_session:=_buoyshell-manager}"

tmux bind-key "$buoy_key" if-shell -F "#{==:#{client_session},$buoy_session}" \
    "detach-client" \
    "run-shell '$CURRENT_DIR/scripts/buoy.sh'"
