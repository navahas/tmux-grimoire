#!/usr/bin/env bash

# Cache tmux display-message and show-option commands to reduce subprocesses
current_session=$(tmux display-message -p '#{client_session}')
current_client=$(tmux display-message -p '#{client_name}')
original_mouse_setting=$(tmux show-option -gv mouse)

# Read buoyshell options individually to maintain compatibility
width=$(tmux show-option -gv '@buoyshell-width')
height=$(tmux show-option -gv '@buoyshell-height')
buoyshell_x=$(tmux show-option -gv '@buoyshell-x')
buoyshell_y=$(tmux show-option -gv '@buoyshell-y')
buoyshell_window_title=$(tmux show-option -gv '@buoyshell-title')
buoyshell_window_color=$(tmux show-option -gv '@buoyshell-color')

buoyshell_session="_buoy-session"

custom_buoy=$1
custom_command=$2
buoyshell_window_name="${custom_buoy:-buoyshell}"
buoyshell_custom_command="${custom_command:-}"
replay_flag=$3

if [[ -n "$custom_buoy" ]]; then
    # Read custom buoy options individually to maintain correct variable assignment
    custom_width=$(tmux show-option -gv "@buoy-${custom_buoy}-width" 2>/dev/null)
    custom_height=$(tmux show-option -gv "@buoy-${custom_buoy}-height" 2>/dev/null)
    custom_x=$(tmux show-option -gv "@buoy-${custom_buoy}-x" 2>/dev/null)
    custom_y=$(tmux show-option -gv "@buoy-${custom_buoy}-y" 2>/dev/null)
    custom_color=$(tmux show-option -gv "@buoy-${custom_buoy}-color" 2>/dev/null)
    custom_title=$(tmux show-option -gv "@buoy-${custom_buoy}-title" 2>/dev/null)

    # Apply custom settings if they exist
    [[ -n "$custom_width" ]] && width="$custom_width"
    [[ -n "$custom_height" ]] && height="$custom_height"
    [[ -n "$custom_x" ]] && buoyshell_x="$custom_x"
    [[ -n "$custom_y" ]] && buoyshell_y="$custom_y"
    [[ -n "$custom_color" ]] && buoyshell_window_color="$custom_color"
    [[ -n "$custom_title" ]] && buoyshell_window_title="$custom_title"
fi

# Set default values if not specified
: "${width:=80%}"
: "${height:=80%}"
: "${buoyshell_x:=C}"
: "${buoyshell_y:=C}"
: "${buoyshell_window_title:=}"
: "${buoyshell_window_color:=}"

popup_title="${buoyshell_window_title}"
[[ -n $custom_buoy ]] && popup_title="${popup_title:+$popup_title|} $custom_buoy "

# Check if session exists with one operation
session_exists=$(tmux has-session -t "$buoyshell_session" 2>/dev/null && echo "yes" || echo "no")

# Create session if it doesn't exist
if [[ "$session_exists" == "no" ]]; then
    TMUX='' tmux new-session -d -s "$buoyshell_session" -n "$buoyshell_window_name"
    tmux set-option -t "$buoyshell_session" status off
fi

# Set detach hook
tmux set-hook -t "$buoyshell_session" client-detached \
    "run-shell 'tmux swap-window -s \"$buoyshell_session:$buoyshell_window_name\" -t \"$current_session:$buoyshell_window_name\"; tmux kill-session -t \"$buoyshell_session\"'"

# Get current session's working directory
session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

# Check if window exists in one operation
window_exists=$(tmux list-windows -t "$current_session" -F "#{window_name}" | grep -x "$buoyshell_window_name" || echo "")

# Create window if it doesn't exist
if [[ -z "$window_exists" ]]; then
    tmux new-window -d -t "$current_session" -n "$buoyshell_window_name" -c "$session_dir"

    if [[ -n $buoyshell_custom_command ]]; then
        tmux send-keys -t "$current_session:$buoyshell_window_name" "clear; bash -c \"${buoyshell_custom_command//\"/\\\"}\"" Enter
    fi
fi

# Check if window exists again after potentially creating it
window_exists=$(tmux list-windows -t "$current_session" -F "#{window_name}" | grep -x "$buoyshell_window_name" || echo "")

# Move window and check if we need to replay the command
if [[ -n "$window_exists" ]]; then
    tmux swap-window -s "$current_session:$buoyshell_window_name" -t "$buoyshell_session:$buoyshell_window_name"

    # Get pane info for child process checking
    pane_pid=$(tmux list-panes -t "$buoyshell_session:$buoyshell_window_name" -F "#{pane_pid}")
    child_procs=$(pgrep -P "$pane_pid" | wc -l)

    if (( child_procs == 0 )); then
        is_idle=true
    else
        is_idle=false
    fi

    if [[ $replay_flag == "--replay" && -n $buoyshell_custom_command && $is_idle == true ]]; then
        tmux send-keys -t "$buoyshell_session:$buoyshell_window_name" "clear; bash -c \"${buoyshell_custom_command//\"/\\\"}\"" Enter
    fi
fi

# Set mouse options and display popup
tmux set-option -g mouse off
tmux display-popup \
    -E \
    -d "$session_dir" \
    -x "$buoyshell_x" \
    -y "$buoyshell_y" \
    -w "$width" -h "$height" \
    -b "rounded" \
    -S "fg=$buoyshell_window_color" \
    -T "$popup_title" \
    "tmux attach-session -t '$buoyshell_session' \; select-window -t '$buoyshell_window_name'"

# Restore original mouse setting
tmux set-option -g mouse "$original_mouse_setting"
