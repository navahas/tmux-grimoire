#!/usr/bin/env bash

grimoire_session="_shpell-session"

custom_shpell=$1
grimoire_custom_command=$2
replay_flag=$3

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

# Probe if a window named $shpell_name exists in $current_session,
# WITHOUT spawning grep/awk (pure Bash), and with exact string match.
# We also strip any stray CRs just in case (some environments can inject them)
window_exists=
while IFS= read -r name; do
    if [[ $name == "$shpell_name" ]]; then
        window_exists=1
        break
    fi
done < <(tmux list-windows -t "$current_session" -F '#{window_name}' 2>/dev/null | tr -d '\r')

# --- Single batched tmux client invocation ---
# TMUX='' unsets the client env var so this command talks to the server
# (critical when running from inside tmux to avoid nesting client state).
# We chain multiple subcommands with '\;' so the *same tmux client* performs
# them sequentially and atomically: one process, one round-trip.
TMUX='' tmux new-session -d -s "$grimoire_session" -n "$shpell_name" -c "$session_dir" \; \
    set-option -t "$grimoire_session" status off \; \
    set-hook -u -t "$grimoire_session" client-detached \; \
    set-hook -t "$grimoire_session" client-detached \
    "run-shell 'tmux swap-window -s \"$grimoire_session:$shpell_name\" \
        -t \"$current_session:$shpell_name\"; \
        tmux kill-session -t \"$grimoire_session\"'"

if [[ -z "$window_exists" ]]; then # window does not exist yet in $current_session
    if [[ -n $grimoire_custom_command ]]; then
        tmux send-keys -t "$grimoire_session:$shpell_name" \
            "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
    fi
    tmux new-window -d -t "$current_session" -n "$shpell_name" -c "$session_dir"

else # window already exists in $current_session
    tmux swap-window -s "$current_session:$shpell_name" -t "$grimoire_session:$shpell_name"

    # Skip all replay/idle probing unless we actually need to replay a command
    if [[ $replay_flag == "--replay" && -n $grimoire_custom_command ]]; then
        # Cheaper "idle-ish" check: current pane command is a shell?
        # - one tmux call instead of pgrep+wc. No extra processes.
        pane_cmd=$(tmux list-panes -t "$grimoire_session:$shpell_name" -F "#{pane_current_command}" | head -n1)
        case "$pane_cmd" in
            bash|zsh|fish) is_idle=1 ;;
            *) is_idle=0 ;;
        esac

        if [[ $is_idle -eq 1 ]]; then
            tmux send-keys -t "$grimoire_session:$shpell_name" \
                "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
        fi
    fi
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
    "tmux select-window -t '$shpell_name' \; \
    attach-session -t '$grimoire_session' \; \
    run-shell 'tmux set-option -t \"$current_session\" mouse \"$original_mouse_setting\"'"
