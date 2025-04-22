#!/usr/bin/env bash

mode=$1 # standard or ephemeral
custom_buoy=$2
custom_buoy="${custom_buoy// /-}" # Replace spaces with dashes
custom_buoy="${custom_buoy//[^a-zA-Z0-9_-]/}" # Strip all non-alphanumeric except - and _
custom_buoy="${custom_buoy,,}" # Convert to lowercase
custom_command=${3:-}
custom_command="${custom_command//\"/\\\"}"  # Escape " early
replay_flag=$4

readonly BUOY_SESSION="_buoy-session"
readonly EPHEMERAL_BUOY_SESSION="_ephemeral-buoy-session"

current_session=$(tmux display-message -p '#{client_session}')

# Handle cleanup: detach or kill related window in original session
if [[ "$current_session" == "$BUOY_SESSION" || "$current_session" == "$EPHEMERAL_BUOY_SESSION" ]]; then
    if [[ "$mode" == "kill" ]]; then
        current_client=$(tmux display-message -p '#{client_name}')
        originating_session=$(tmux display-message -p -t "$current_client" '#{client_session}')
        session=$(tmux list-clients -F '#{client_session}' | grep -v '_buoy-session' | grep -v '_ephemeral-buoy-session' | head -n1)
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

# Resolve buoy script base path
buoyspath=$(tmux show-option -gv '@buoyshell-buoyspath' 2>/dev/null)
: "${buoyspath:=$HOME/.config/custom-buoys}"

if [[ "$custom_command" == buoys/* ]]; then
  custom_command="$buoyspath/${custom_command#buoys/}"
fi

# Launch appropriate buoy type based on mode
if [[ "standard" == "${mode}" ]]; then
    # Launch in background to improve perceived responsiveness
    (. ~/.tmux/plugins/tmux-buoyshell/scripts/buoy.sh "$custom_buoy" "$custom_command" "$replay_flag" &)
elif [[ "ephemeral" == "${mode}" ]]; then
    (. ~/.tmux/plugins/tmux-buoyshell/scripts/ephemeral_buoy.sh "$custom_buoy" "$custom_command" &)
fi
