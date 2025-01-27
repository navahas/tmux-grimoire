#!/usr/bin/env bash

# Get the current session name (parent session, even in a popup)
current_session=$(tmux display-message -p '#{client_session}')
current_client=$(tmux display-message -p '#{client_name}')
session_name=$(tmux show-option -gv '@buoyshell-session')
width=$(tmux show-option -gv '@buoyshell-width')
height=$(tmux show-option -gv '@buoyshell-height')
_x=$(tmux show-option -gv '@buoyshell-x')
_y=$(tmux show-option -gv '@buoyshell-y')
temp_window="_tty"

: "${session_name:=_buoyshell-manager}"
: "${width:=80%}"
: "${height:=80%}"
: "${_x:=R}"
: "${_y:=S}"

# Check if session_name exists and create if doesn't
tmux has-session -t "$session_name" 2>/dev/null
if [[ $? -ne 0 ]]; then
    TMUX='' tmux new-session -d -s "$session_name" -n "$temp_window"
    tmux set-option -t "$session_name" status off
fi

# Move the window back to the original session when the popup is detached
tmux set-hook -t "$session_name" client-detached "run-shell 'tmux swap-window -s \"$session_name:$window_name\" -t \"$current_session:1\"'"

window_name="buoyshell_$current_session"
session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

# Check if the current session has a window in position :1
if tmux list-windows -t "$current_session" -F '#{window_index}' | grep -q '^1$'; then
    # Rename the window in position :1 to buoy_<session_name>
    tmux rename-window -t "$current_session:1" "$window_name"
else
    # Create a new window in position :1 for the current session
    tmux new-window -d -t "$current_session:1" -n "$window_name" -c "$session_dir"
fi

# Check if shell for the current session already exists in the popup session
if ! tmux list-windows -t "$session_name" -F '#{window_name}' | grep -q "^$window_name$"; then
    tmux new-window -d -t "$session_name" -n "$window_name" -c "$session_dir"
fi

# Ensure temp_window is cleaned
tmux kill-window -t "$session_name:$temp_window" 2>/dev/null

# Move the window from the current session to the manager session
tmux swap-window -s "$current_session:1" -t "$session_name:$window_name"

# Launch Popup
tmux display-popup \
  -E \
  -d '#{pane_current_path}' \
  -x"$_x" -y"$_y" \
  -w"$width" -h"$height" \
  -T " session: $current_session " \
  "tmux attach-session -t '$session_name' \; select-window -t '$window_name'"
