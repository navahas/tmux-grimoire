#!/usr/bin/env bash

current_session=$(tmux display-message -p '#{client_session}')
current_client=$(tmux display-message -p '#{client_name}')
original_mouse_setting=$(tmux show-option -gv mouse)
buoyshell_width=$(tmux show-option -gv '@buoyshell-width')
buoyshell_height=$(tmux show-option -gv '@buoyshell-height')
buoyshell_x=$(tmux show-option -gv '@buoyshell-x')
buoyshell_y=$(tmux show-option -gv '@buoyshell-y')
buoyshell_window_title=$(tmux show-option -gv '@buoyshell-title')
buoyshell_window_color=$(tmux show-option -gv '@buoyshell-color')
buoyshell_session="_ephemeral-buoy-session"
temp_window="_tty"

custom_buoy=$1
buoyshell_custom_command=$2

if [[ -n "$custom_buoy" ]]; then
    custom_width=$(tmux show-option -gv "@buoy-${custom_buoy}-width" 2>/dev/null)
    custom_height=$(tmux show-option -gv "@buoy-${custom_buoy}-height" 2>/dev/null)
    custom_x=$(tmux show-option -gv "@buoy-${custom_buoy}-x" 2>/dev/null)
    custom_y=$(tmux show-option -gv "@buoy-${custom_buoy}-y" 2>/dev/null)
    custom_color=$(tmux show-option -gv "@buoy-${custom_buoy}-color" 2>/dev/null)

    [[ -n "$custom_width" ]] && buoyshell_width="$custom_width"
    [[ -n "$custom_height" ]] && buoyshell_height="$custom_height"
    [[ -n "$custom_x" ]] && buoyshell_x="$custom_x"
    [[ -n "$custom_y" ]] && buoyshell_y="$custom_y"
    [[ -n "$custom_color" ]] && buoyshell_window_color="$custom_color"
fi

: "${buoyshell_width:=80%}"
: "${buoyshell_height:=80%}"
: "${buoyshell_x:=C}"
: "${buoyshell_y:=C}"
: "${buoyshell_window_title:=}"
: "${buoyshell_window_color:=}"

popup_title="${buoyshell_window_title}"
[[ -n $custom_buoy ]] && popup_title="${popup_title:+$popup_title|} $custom_buoy "

session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

if [[ -n $buoyshell_custom_command ]]; then
    TMUX='' tmux new-session -d -s "$buoyshell_session" -n "$temp_window" -c "$session_dir" \; \
        set-option -t "$buoyshell_session" status off \; \
        send-keys -t "$buoyshell_session:$temp_window" "tput clear; bash -c \"${buoyshell_custom_command//\"/\\\"}\"" Enter
else
    TMUX='' tmux new-session -d -s "$buoyshell_session" -n "$temp_window" -c "$session_dir" \; \
        set-option -t "$buoyshell_session" status off
fi

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
    "tmux attach-session -t '$buoyshell_session' \; select-window -t '$temp_window'"

tmux run-shell "sleep 0.3 && tmux kill-session -t '$buoyshel_session'" &
tmux set-option -g mouse "$original_mouse_setting"
