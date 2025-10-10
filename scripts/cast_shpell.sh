#!/usr/bin/env bash

# Resolve script directory dynamically to support any plugin installation path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments and sanitize custom shpell name for safe session/window naming
mode=$1 # standard or ephemeral
custom_shpell=$2
custom_shpell="${custom_shpell// /-}" # Replace spaces with dashes
custom_shpell="${custom_shpell//[^a-zA-Z0-9_-]/}" # Strip all non-alphanumeric except - and _
custom_shpell="${custom_shpell,,}" # Convert to lowercase
custom_command=${3:-}
custom_command="${custom_command//\"/\\\"}"  # Escape " early
replay_flag=$4

readonly SHPELL_SESSION="_shpell-session"
readonly EPHEMERAL_SHPELL_SESSION="_ephemeral-shpell-session"

current_session=$(tmux display-message -p '#{client_session}')

# Handle cleanup: detach or kill related window in original session
if [[ "$current_session" == "$SHPELL_SESSION" || "$current_session" == "$EPHEMERAL_SHPELL_SESSION" ]]; then
    if [[ "$mode" == "kill" ]]; then
        current_client=$(tmux display-message -p '#{client_name}')
        window_name=$(tmux display-message -p -t "$current_client" '#{window_name}')

        # Find first non-shpell session using bash pattern matching (avoids grep subprocess overhead)
        # Process substitution with early break - stops at first match instead of filtering all sessions
        session=""
        while IFS= read -r s; do
            [[ $s != "$SHPELL_SESSION" && $s != "$EPHEMERAL_SHPELL_SESSION" ]] && { session=$s; break; }
        done < <(tmux list-clients -F '#{client_session}')

        if [[ -n "$session" ]]; then
            # Direct tmux query for window existence (replaces list-windows | grep pipeline)
            # Silent failure check - exits on error instead of parsing full window list
            if tmux display-message -p -t "$session:$window_name" '#{window_id}' >/dev/null 2>&1; then
                tmux kill-window -t "$session:$window_name"
            fi
        fi

        tmux detach-client
    else
        tmux detach-client
    fi
    exit 0
fi

# Resolve grimoire base path
grimoirepath=$(tmux show-option -gv '@grimoire-path' 2>/dev/null)
: "${grimoirepath:=$HOME/.config/grimoire}"

if [[ "$custom_command" == shpell/* ]]; then
  custom_command="$grimoirepath/${custom_command#shpell/}"
fi

# Launch the appropriate shpell type based on mode
# Spawn as a detached background process to keep tmux responsive
# (no sourcing, no blocking)
if [[ "standard" == "${mode}" ]]; then
    "$SCRIPT_DIR/shpell.sh" "$custom_shpell" "$custom_command" "$replay_flag" &
elif [[ "ephemeral" == "${mode}" ]]; then
    "$SCRIPT_DIR/ephemeral_shpell.sh" "$custom_shpell" "$custom_command" &
fi
