#!/usr/bin/env bash

current_session=$(tmux display-message -p '#{client_session}')
current_client=$(tmux display-message -p '#{client_name}')
original_mouse_setting=$(tmux show-option -gv mouse)
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

: "${width:=80%}"
: "${height:=80%}"
: "${buoyshell_x:=C}"
: "${buoyshell_y:=C}"
: "${buoyshell_window_title:=}"
: "${buoyshell_window_color:=}"

popup_title="${buoyshell_window_title}"
[[ -n $custom_buoy ]] && popup_title="${popup_title:+$popup_title|} $custom_buoy "

if ! tmux has-session -t "$buoyshell_session" 2>/dev/null; then
    TMUX='' tmux new-session -d -s "$buoyshell_session" -n "$buoyshell_window_name"
    tmux set-option -t "$buoyshell_session" status off
fi

tmux set-hook -t "$buoyshell_session" client-detached \
    "run-shell 'tmux swap-window -s \"$buoyshell_session:$buoyshell_window_name\" -t \"$current_session:$buoyshell_window_name\"; tmux kill-session -t \"$buoyshell_session\"'"

# Get the current session's working directory
session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

# Ensure a window named "buoyshell" exists in the current session
if ! tmux list-windows -t "$current_session" -F "#{window_name}" | grep -qx "$buoyshell_window_name"; then
    tmux new-window -d -t "$current_session" -n "$buoyshell_window_name" -c "$session_dir"

    if [[ -n $buoyshell_custom_command ]]; then
        tmux send-keys -t "$current_session:$buoyshell_window_name" "clear; bash -c \"${buoyshell_custom_command//\"/\\\"}\"" Enter
    fi
fi

# Move the "buoyshell" window from the current session to the manager session
if tmux list-windows -t "$current_session" -F "#{window_name}" | grep -qx "$buoyshell_window_name"; then
    tmux swap-window -s "$current_session:$buoyshell_window_name" -t "$buoyshell_session:$buoyshell_window_name"

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

# Debuging panes
# tmux display-message "X: $buoyshell_x, Y: $buoyshell_y, Width: $width, Height: $height"

tmux set-option -g mouse off
tmux display-popup \
    -E \
    -d '#{pane_current_path}' \
    -x "$buoyshell_x" \
    -y "$buoyshell_y" \
    -w "$width" -h "$height" \
    -b "rounded" \
    -S "fg=$buoyshell_window_color" \
    -T "$popup_title" \
    "tmux attach-session -t '$buoyshell_session' \; select-window -t '$buoyshell_window_name'"

tmux set-option -g mouse "$original_mouse_setting"
