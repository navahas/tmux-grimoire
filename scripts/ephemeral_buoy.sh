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
buoyshell_session="_ephemeral-buoy-session"
temp_window="_tty"

custom_buoy=$1
custom_command=$2
buoyshell_custom_command="${custom_command:-}"

if [[ -n "$custom_buoy" ]]; then
    custom_width=$(tmux show-option -gv "@buoy-${custom_buoy}-width" 2>/dev/null)
    custom_height=$(tmux show-option -gv "@buoy-${custom_buoy}-height" 2>/dev/null)
    custom_x=$(tmux show-option -gv "@buoy-${custom_buoy}-x" 2>/dev/null)
    custom_y=$(tmux show-option -gv "@buoy-${custom_buoy}-y" 2>/dev/null)
    custom_color=$(tmux show-option -gv "@buoy-${custom_buoy}-color" 2>/dev/null)
    custom_title=$(tmux show-option -gv "@buoy-${custom_buoy}-title" 2>/dev/null)

    [[ -n "$custom_width" ]] && buoyshell_width="$custom_width"
    [[ -n "$custom_height" ]] && buoyshell_height="$custom_height"
    [[ -n "$custom_x" ]] && buoyshell_x="$custom_x"
    [[ -n "$custom_x" ]] && buoyshell_x="$custom_x"
    [[ -n "$custom_y" ]] && buoyshell_y="$custom_y"
    [[ -n "$custom_color" ]] && buoyshell_window_color="$custom_color"
    [[ -n "$custom_title" ]] && buoyshell_window_title="$custom_title"
fi

: "${buoyshell_width:=80%}"
: "${buoyshell_height:=80%}"
: "${buoyshell_x:=C}"
: "${buoyshell_y:=C}"
: "${buoyshell_window_title:=}"
: "${buoyshell_window_color:=}"

popup_title="${buoyshell_window_title}"
[[ -n $custom_buoy ]] && popup_title="${popup_title:+$popup_title|} $custom_buoy "

if ! tmux has-session -t "$buoyshell_session" 2>/dev/null; then
    TMUX='' tmux new-session -d -s "$buoyshell_session" -n "$temp_window"
    tmux set-option -t "$buoyshell_session" status off
fi

tmux set-hook -t "$buoyshell_session" client-detached \
    "run-shell 'tmux kill-window -t \"$current_session\"'"

# Get the current session's working directory
session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

# Ensure a window for the current session exists in the buoyshell-manager session
if ! tmux list-windows -t "$buoyshell_session" -F "#{window_name}" | grep -qx "$current_session"; then
    tmux new-window -d -t "$buoyshell_session" -n "$current_session" -c "$session_dir"

    if [[ -n $buoyshell_custom_command ]]; then
        tmux send-keys -t "$buoyshell_session:$current_session" "tput clear; bash -c \"${buoyshell_custom_command//\"/\\\"}\"" Enter
    fi
fi


tmux kill-window -t "$buoyshell_session:$temp_window" 2>/dev/null

tmux set-option -g mouse off
tmux display-popup \
    -E \
    -d '#{pane_current_path}' \
    -x "$buoyshell_x" \
    -y "$buoyshell_y" \
    -w "$buoyshell_width" -h "$buoyshell_height" \
    -b "rounded" \
    -S "fg=$buoyshell_window_color" \
    -T "$popup_title" \
    "tmux attach-session -t '$buoyshell_session' \; select-window -t '$current_session'"

tmux set-option -g mouse "$original_mouse_setting"
