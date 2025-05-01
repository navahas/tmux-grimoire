#!/usr/bin/env bash

current_session=$(tmux display-message -p '#{client_session}')
current_client=$(tmux display-message -p '#{client_name}')
original_mouse_setting=$(tmux show-option -gv mouse)
grimoire_width=$(tmux show-option -gv '@grimoire-width')
grimoire_height=$(tmux show-option -gv '@grimoire-height')
grimoire_x=$(tmux show-option -gv '@grimoire-x')
grimoire_y=$(tmux show-option -gv '@grimoire-y')
grimoire_window_title=$(tmux show-option -gv '@grimoire-title')
grimoire_window_color=$(tmux show-option -gv '@grimoire-color')
grimoire_session="_shpell-session"

custom_shpell=$1
grimoire_custom_command=$2
grimoire_window_name="${custom_shpell:-grimoire}"
replay_flag=$3

if [[ -n "$custom_shpell" ]]; then
    custom_width=$(tmux show-option -gv "@shpell-${custom_shpell}-width" 2>/dev/null)
    custom_height=$(tmux show-option -gv "@shpell-${custom_shpell}-height" 2>/dev/null)
    custom_x=$(tmux show-option -gv "@shpell-${custom_shpell}-x" 2>/dev/null)
    custom_y=$(tmux show-option -gv "@shpell-${custom_shpell}-y" 2>/dev/null)
    custom_color=$(tmux show-option -gv "@shpell-${custom_shpell}-color" 2>/dev/null)

    [[ -n "$custom_width" ]] && grimoire_width="$custom_width"
    [[ -n "$custom_height" ]] && grimoire_height="$custom_height"
    [[ -n "$custom_x" ]] && grimoire_x="$custom_x"
    [[ -n "$custom_y" ]] && grimoire_y="$custom_y"
    [[ -n "$custom_color" ]] && grimoire_window_color="$custom_color"
fi

: "${grimoire_width:=80%}"
: "${grimoire_height:=80%}"
: "${grimoire_x:=C}"
: "${grimoire_y:=C}"
: "${grimoire_window_title:=}"
: "${grimoire_window_color:=}"

popup_title="${grimoire_window_title}"
[[ -n $custom_shpell ]] && popup_title="${popup_title:+$popup_title|} $custom_shpell "

session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')
window_exists=$(tmux list-windows -t "$current_session" -F "#{window_name}" | grep -x "$grimoire_window_name" || echo "")

TMUX='' tmux new-session -d -s "$grimoire_session" -n "$grimoire_window_name" -c "$session_dir" \; \
    set-option -t "$grimoire_session" status off \; \

# Set detach hook
tmux set-hook -t "$grimoire_session" client-detached \
    "run-shell 'tmux swap-window -s \"$grimoire_session:$grimoire_window_name\" -t \"$current_session:$grimoire_window_name\"; tmux kill-session -t \"$grimoire_session\"'"

if [[ -z "$window_exists" ]]; then
    if [[ -n $grimoire_custom_command ]]; then
        tmux send-keys -t "$grimoire_session:$grimoire_window_name" "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
    fi

    tmux new-window -d -t "$current_session" -n "$grimoire_window_name" -c "$session_dir"
fi

if [[ -n "$window_exists" ]]; then
    tmux swap-window -s "$current_session:$grimoire_window_name" -t "$grimoire_session:$grimoire_window_name"

    # Get pane info for child process checking
    pane_pid=$(tmux list-panes -t "$grimoire_session:$grimoire_window_name" -F "#{pane_pid}")
    child_procs=$(pgrep -P "$pane_pid" | wc -l)

    if (( child_procs == 0 )); then
        is_idle=true
    else
        is_idle=false
    fi

    if [[ $replay_flag == "--replay" && -n $grimoire_custom_command && $is_idle == true ]]; then
        tmux send-keys -t "$grimoire_session:$grimoire_window_name" "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
    fi
fi

tmux set-option -g mouse off
tmux display-popup \
    -E \
    -d "$session_dir" \
    -x "$grimoire_x" \
    -y "$grimoire_y" \
    -w "$grimoire_width" -h "$grimoire_height" \
    -b "rounded" \
    -S "fg=$grimoire_window_color" \
    -T "$popup_title" \
    "tmux attach-session -t '$grimoire_session' \; select-window -t '$grimoire_window_name'"

tmux set-option -g mouse "$original_mouse_setting"
