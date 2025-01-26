#!/usr/bin/env bash

# Check for tmux
if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed"
    exit 1
fi

# Constants and defaults
PLUGIN_NAME="buoyshell"
DEFAULT_CONFIG=(
    "MANAGER_SESSION=_buoyshell-manager"
    "POPUP_WIDTH=80%"
    "POPUP_HEIGHT=80%"
    "POPUP_TITLE= session: #{session_name} "
    "CLEANUP_ORPHANS=true"
)

# Load user config if exists
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/$PLUGIN_NAME/config"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Set defaults for unset variables
for config in "${DEFAULT_CONFIG[@]}"; do
    key="${config%%=*}"
    default="${config#*=}"
    declare -g "${key}=${!key:-$default}"
done

cleanup_orphaned_windows() {
    local manager_session="$1"
    local existing_sessions
    
    existing_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
    
    # Get all windows in manager session
    tmux list-windows -t "$manager_session" -F "#{window_name}" 2>/dev/null | while read -r window; do
        # Skip special windows
        [[ "$window" == "_tty" ]] && continue
        
        # Check if corresponding session exists
        if ! echo "$existing_sessions" | grep -q "^$window$"; then
            tmux kill-window -t "$manager_session:$window" 2>/dev/null
        fi
    done
}

main() {
    # Get current session info
    local current_session
    current_session=$(tmux display-message -p '#{client_session}')
    
    if [[ -z "$current_session" ]]; then
        echo "Error: Could not determine current session"
        exit 1
    }
    
    local session_dir
    session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

    # Ensure manager session exists
    if ! tmux has-session -t "$MANAGER_SESSION" 2>/dev/null; then
        TMUX='' tmux new-session -d -s "$MANAGER_SESSION" -n "_tty"
        tmux set-option -t "$MANAGER_SESSION" status off
    fi

    # Create window for current session if needed
    if ! tmux list-windows -t "$MANAGER_SESSION" -F '#{window_name}' | grep -q "^$current_session$"; then
        tmux new-window -d -t "$MANAGER_SESSION" -n "$current_session" -c "$session_dir"
    fi

    # Cleanup orphaned windows if enabled
    [[ "$CLEANUP_ORPHANS" == "true" ]] && cleanup_orphaned_windows "$MANAGER_SESSION"

    # Kill temporary window if it exists
    tmux kill-window -t "$MANAGER_SESSION:_tty" 2>/dev/null

    # Launch popup
    tmux display-popup \
        -E \
        -d "$session_dir" \
        -xC -yC \
        -w"$POPUP_WIDTH" -h"$POPUP_HEIGHT" \
        -T "$POPUP_TITLE" \
        "tmux attach-session -t '$MANAGER_SESSION' \; select-window -t '$current_session'"
}

export MANAGER_SESSION
