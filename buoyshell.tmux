#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buoy_key=$(tmux show-option -gv '@buoyshell-key')
ephemeral_buoy_key=$(tmux show-option -gv '@ephemeral-buoyshell-key')
buoy_session="_buoy-session"
ephemeral_buoy_session="_ephemeral-buoy-session"

: "${buoy_key:=f}"
: "${ephemeral_buoy_key:=F}"

# Persistent Buoyshell
# tmux bind-key "$buoy_key" if-shell -F "#{==:#{client_session},$buoy_session}" \
#     "detach-client" \
#     "run-shell '$CURRENT_DIR/scripts/buoy.sh'"
# 
# # Ephemeral Buoyshell
# tmux bind-key "$ephemeral_buoy_key" if-shell -F "#{==:#{client_session},$ephemeral_buoy_session}" \
#     "detach-client" \
#     "run-shell '$CURRENT_DIR/scripts/ephemeral_buoy.sh'"

# Universal detach or invoke for Persistent Buoy
tmux bind-key "$buoy_key" run-shell " \
    current_session=\$(tmux display-message -p '#{client_session}'); \
    if [[ \"\$current_session\" == \"$ephemeral_buoy_session\" ]]; then \
        tmux detach-client -s \"$ephemeral_buoy_session\"; \
    elif [[ \"\$current_session\" == \"$buoy_session\" ]]; then \
        tmux detach-client -s \"$buoy_session\"; \
    else \
        '$CURRENT_DIR/scripts/buoy.sh'; \
    fi"

# Universal detach or invoke for Ephemeral Buoy
tmux bind-key "$ephemeral_buoy_key" run-shell " \
    current_session=\$(tmux display-message -p '#{client_session}'); \
    if [[ \"\$current_session\" == \"$buoy_session\" ]]; then \
        tmux detach-client -s \"$buoy_session\"; \
    elif [[ \"\$current_session\" == \"$ephemeral_buoy_session\" ]]; then \
        tmux detach-client -s \"$ephemeral_buoy_session\"; \
        tmux kill-session -t \"$ephemeral_buoy_session\"; \
    else \
        '$CURRENT_DIR/scripts/ephemeral_buoy.sh'; \
    fi"
