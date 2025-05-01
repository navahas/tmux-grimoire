#!/usr/bin/env bash

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
        originating_session=$(tmux display-message -p -t "$current_client" '#{client_session}')
        session=$(tmux list-clients -F '#{client_session}' | grep -v '_shpell-session' | grep -v '_ephemeral-shpell-session' | head -n1)
        window_name=$(tmux display-message -p -t "$current_client" '#{window_name}')

        if [[ -n "$session" ]]; then
            if tmux list-windows -t "$session" -F "#{window_name}" | grep -Fxq "$window_name"; then
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

# Launch appropriate shpell type based on mode
if [[ "standard" == "${mode}" ]]; then
    # Launch in background to improve perceived responsiveness
    (. ~/.tmux/plugins/tmux-grimoire/scripts/shpell.sh "$custom_shpell" "$custom_command" "$replay_flag" &)
elif [[ "ephemeral" == "${mode}" ]]; then
    (. ~/.tmux/plugins/tmux-grimoire/scripts/ephemeral_shpell.sh "$custom_shpell" "$custom_command" &)
fi
