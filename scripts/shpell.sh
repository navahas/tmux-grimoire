#!/usr/bin/env bash

current_session=$(tmux display-message -p '#{client_session}')
current_client=$(tmux display-message -p '#{client_name}')
original_mouse_setting=$(tmux show-option -gv mouse)
grimoire_width=$(tmux show-option -gv '@grimoire-width')
grimoire_height=$(tmux show-option -gv '@grimoire-height')
grimoire_position=$(tmux show-option -gv "@grimoire-position")
grimoire_window_title=$(tmux show-option -gv '@grimoire-title')
grimoire_window_color=$(tmux show-option -gv '@grimoire-color')
grimoire_session="_shpell-session"

custom_shpell=$1
grimoire_custom_command=$2
replay_flag=$3

if [[ -n "$custom_shpell" ]]; then
    custom_position=$(tmux show-option -gv "@shpell-${custom_shpell}-position" 2>/dev/null)
    custom_width=$(tmux show-option -gv "@shpell-${custom_shpell}-width" 2>/dev/null)
    custom_height=$(tmux show-option -gv "@shpell-${custom_shpell}-height" 2>/dev/null)
    custom_color=$(tmux show-option -gv "@shpell-${custom_shpell}-color" 2>/dev/null)

    [[ -n "$custom_position" ]] && grimoire_position="$custom_position"
    [[ -n "$custom_width" ]] && grimoire_width="$custom_width"
    [[ -n "$custom_height" ]] && grimoire_height="$custom_height"
    [[ -n "$custom_color" ]] && grimoire_window_color="$custom_color"
fi

case "$grimoire_position" in
  top-left)      grimoire_x='P'; grimoire_y='M' ;;
  top-center)    grimoire_x='C'; grimoire_y='M' ;;
  top-right)     grimoire_x='W'; grimoire_y='M' ;;
  bottom-left)   grimoire_x='P'; grimoire_y='S' ;;
  bottom-center) grimoire_x='C'; grimoire_y='S' ;;
  bottom-right)  grimoire_x='W'; grimoire_y='S' ;;
  left)          grimoire_x='P'; grimoire_y='C' ;;
  right)         grimoire_x='W'; grimoire_y='C' ;;
  center)        grimoire_x='C'; grimoire_y='C' ;;
  *)             grimoire_x='C'; grimoire_y='C' ;; # default to center
esac

: "${grimoire_width:=80%}"
: "${grimoire_height:=80%}"
: "${grimoire_window_title:=}"
: "${grimoire_window_color:=}"

grimoire_name="${grimoire_window_title:-}"
shpell_name="${custom_shpell:-main}"
popup_title="$grimoire_name| $shpell_name "

session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')
window_exists=$(tmux list-windows -t "$current_session" -F "#{window_name}" | grep -x "$shpell_name" || echo "")

TMUX='' tmux new-session -d -s "$grimoire_session" -n "$shpell_name" -c "$session_dir" \; \
    set-option -t "$grimoire_session" status off \; \

# Set detach hook
tmux set-hook -u -t "$grimoire_session" client-detached
tmux set-hook -t "$grimoire_session" client-detached \
    "run-shell 'tmux swap-window -s \"$grimoire_session:$shpell_name\" -t \"$current_session:$shpell_name\"; tmux kill-session -t \"$grimoire_session\"'"

if [[ -z "$window_exists" ]]; then
    if [[ -n $grimoire_custom_command ]]; then
        tmux send-keys -t "$grimoire_session:$shpell_name" "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
    fi

    tmux new-window -d -t "$current_session" -n "$shpell_name" -c "$session_dir"
fi

if [[ -n "$window_exists" ]]; then
    tmux swap-window -s "$current_session:$shpell_name" -t "$grimoire_session:$shpell_name"

    # Get pane info for child process checking
    pane_pid=$(tmux list-panes -t "$grimoire_session:$shpell_name" -F "#{pane_pid}")
    child_procs=$(pgrep -P "$pane_pid" | wc -l)

    if (( child_procs == 0 )); then
        is_idle=true
    else
        is_idle=false
    fi

    if [[ $replay_flag == "--replay" && -n $grimoire_custom_command && $is_idle == true ]]; then
        tmux send-keys -t "$grimoire_session:$shpell_name" "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
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
    "tmux attach-session -t '$grimoire_session' \; select-window -t '$shpell_name'"

tmux set-option -g mouse "$original_mouse_setting"
