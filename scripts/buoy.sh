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
buoyshell_session="_buoy-session"

custom_buoy=$1
buoyshell_custom_command=$2
buoyshell_window_name="${custom_buoy:-buoyshell}"
replay_flag=$3

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
window_exists=$(tmux list-windows -t "$current_session" -F "#{window_name}" | grep -x "$buoyshell_window_name" || echo "")

TMUX='' tmux new-session -d -s "$buoyshell_session" -n "$buoyshell_window_name" -c "$session_dir" \; \
    set-option -t "$buoyshell_session" status off \; \

# Set detach hook
tmux set-hook -t "$buoyshell_session" client-detached \
    "run-shell 'tmux swap-window -s \"$buoyshell_session:$buoyshell_window_name\" -t \"$current_session:$buoyshell_window_name\"; tmux kill-session -t \"$buoyshell_session\"'"

if [[ -z "$window_exists" ]]; then
    if [[ -n $buoyshell_custom_command ]]; then
        tmux send-keys -t "$buoyshell_session:$buoyshell_window_name" "clear; bash -c \"${buoyshell_custom_command//\"/\\\"}\"" Enter
    fi

    tmux new-window -d -t "$current_session" -n "$buoyshell_window_name" -c "$session_dir"
fi

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

tmux set-option -g mouse off
tmux display-popup \
    -E \
    -d "$session_dir" \
    -x "$buoyshell_x" \
    -y "$buoyshell_y" \
    -w "$buoyshell_width" -h "$buoyshell_height" \
    -b "rounded" \
    -S "fg=$buoyshell_window_color" \
    -T "$popup_title" \
    "tmux attach-session -t '$buoyshell_session' \; select-window -t '$buoyshell_window_name'"

tmux set-option -g mouse "$original_mouse_setting"
