#!/usr/bin/env bash

grimoire_session="_ephemeral-shpell-session"

custom_shpell=$1
grimoire_custom_command=$2
temp_window="_tty"

# SINGLE-IPC OPTION FETCH
# We batch all tmux option/pane reads into one "display-message -p":
#   - One tmux client -> one IPC round trip -> lower latency.
#   - Each format prints on its own line; we read lines into vals[] with a Bash-3.2-compatible while-read.
#   - Use an explicit target (-t "$target") so pane/session formats resolve from scripts or hooks.
#   - CRITICAL: Do NOT indent the format lines. Leading whitespace becomes part of the format and breaks tmux parsing.
target="${TMUX_PANE:-}:"
i=0
while IFS= read -r line; do
    vals[$i]="$line"
    ((i++))
done < <(tmux display-message -p -t "$target" '#{?@grimoire-width,#{@grimoire-width},}
#{?@grimoire-height,#{@grimoire-height},}
#{?@grimoire-position,#{@grimoire-position},}
#{?@grimoire-title,#{@grimoire-title},}
#{?@grimoire-color,#{@grimoire-color},}
#{session_name}
#{pane_current_path}
#{?default-path,#{default-path},}
#{mouse}')

grimoire_width=${vals[0]}
grimoire_height=${vals[1]}
grimoire_position=${vals[2]}
grimoire_window_title=${vals[3]}
grimoire_window_color=${vals[4]}
current_session=${vals[5]}
pane_current_path=${vals[6]}
default_path=${vals[7]}
original_mouse_setting=${vals[8]}

if [[ -n "$custom_shpell" ]]; then
    i=0
    while IFS= read -r line; do
        custom_vals[$i]="$line"
        ((i++))
#!! Indentation 
    done < <(tmux display-message -p -t "$target" "#{?@shpell-${custom_shpell}-position,#{@shpell-${custom_shpell}-position},}
#{?@shpell-${custom_shpell}-width,#{@shpell-${custom_shpell}-width},}
#{?@shpell-${custom_shpell}-height,#{@shpell-${custom_shpell}-height},}
#{?@shpell-${custom_shpell}-color,#{@shpell-${custom_shpell}-color},}")

    [[ -n "${custom_vals[0]}" ]] && grimoire_position="${custom_vals[0]}"
    [[ -n "${custom_vals[1]}" ]] && grimoire_width="${custom_vals[1]}"
    [[ -n "${custom_vals[2]}" ]] && grimoire_height="${custom_vals[2]}"
    [[ -n "${custom_vals[3]}" ]] && grimoire_window_color="${custom_vals[3]}"
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

# Working dir: use pre-fetched pane_current_path -> default-path -> $PWD
session_dir="${pane_current_path:-${default_path:-$PWD}}"

# --- Single batched tmux client invocation ---
# TMUX='' unsets the client env var so this command talks to the server
# (critical when running from inside tmux to avoid nesting client state).
# We chain multiple subcommands with '\;' so the *same tmux client* performs
# them sequentially and atomically: one process, one round-trip.
if [[ -n $grimoire_custom_command ]]; then
    TMUX='' tmux new-session -d -s "$grimoire_session" -n "$temp_window" -c "$session_dir" \; \
        set-option -t "$grimoire_session" status off \; \
        set-hook -u -t "$grimoire_session" client-detached \; \
        set-hook -t "$grimoire_session" client-detached \
        "run-shell 'tmux kill-session -t \"$grimoire_session\"'" \; \
        send-keys -t "$grimoire_session:$temp_window" "tput clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
else
    TMUX='' tmux new-session -d -s "$grimoire_session" -n "$temp_window" -c "$session_dir" \; \
        set-option -t "$grimoire_session" status off \; \
        set-hook -u -t "$grimoire_session" client-detached \; \
        set-hook -t "$grimoire_session" client-detached \
        "run-shell 'tmux kill-session -t \"$grimoire_session\"'"
fi

# --- Single batched tmux client invocation ---
tmux \
    set-option -t "$current_session" mouse off \; \
    display-popup \
    -E \
    -d "$session_dir" \
    -x "$grimoire_x" \
    -y "$grimoire_y" \
    -w "$grimoire_width" -h "$grimoire_height" \
    -b "rounded" \
    -S "fg=$grimoire_window_color" \
    -T "$popup_title" \
    "tmux attach-session -t '$grimoire_session' \; \
    select-window -t '$temp_window' \; \
    run-shell 'tmux set-option -t \"$current_session\" mouse \"$original_mouse_setting\"'"
