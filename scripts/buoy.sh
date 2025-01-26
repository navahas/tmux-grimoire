#!/usr/bin/env bash

# Get the current session name (parent session, even in a popup)
current_session=$(tmux display-message -p '#{client_session}')
current_client=$(tmux display-message -p '#{client_name}')
session_name="_buoyshell-manager"
temp_window="_tty"

# Check if session_name exists and create if doesn't
tmux has-session -t "$session_name" 2>/dev/null
if [[ $? -ne 0 ]]; then
    TMUX='' tmux new-session -d -s "$session_name" -n "$temp_window"
    tmux set-option -t "$session_name" status off
fi

window_name="$current_session"
session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

# Check if shell for the current session already exists in the popup session
if ! tmux list-windows -t "$session_name" -F '#{window_name}' | grep -q "^$window_name$"; then
    tmux new-window -d -t "$session_name" -n "$window_name" -c "$session_dir"
fi

# Ensure temp_window is cleaned
tmux kill-window -t "$session_name:$temp_window" 2>/dev/null

# Launch Popup
tmux display-popup \
  -E \
  -d '#{pane_current_path}' \
  -xC -yC \
  -w80% -h80% \
  -T " session: #{session_name} " \
  "tmux attach-session -t '$session_name' \; select-window -t '$current_session'"
