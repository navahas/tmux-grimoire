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

# Probe by window name (preserves manual rename workflow),
# but capture the immutable window ID (wid, e.g. @0, @5) for swap targeting.
# Format per line: "window_name|@N" -> read into: name|wid
placeholder_id=
while IFS='|' read -r name wid; do
    if [[ $name == "$shpell_name" ]]; then
        placeholder_id="$wid"
        break
    fi
done < <(tmux list-windows -t "$current_session:" -F '#{window_name}|#{window_id}' 2>/dev/null)

# --- Create grimoire session, capture window ID ---
grimoire_wid=$(TMUX='' tmux new-session -d -s "$grimoire_session" -n "$shpell_name" \
    -c "$session_dir" -P -F '#{window_id}' \; \
    set-option -t "$grimoire_session" status off)

if [[ -z "$placeholder_id" ]]; then # window does not exist yet in $current_session
    if [[ -n $grimoire_custom_command ]]; then
        tmux send-keys -t "$grimoire_wid" \
            "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
    fi
    placeholder_id=$(tmux new-window -d -t "$current_session:" -n "$shpell_name" \
        -c "$session_dir" -P -F '#{window_id}')
    popup_wid="$grimoire_wid"

else # window already exists in $current_session
    tmux swap-window -s "$placeholder_id" -t "$grimoire_wid"
    popup_wid="$placeholder_id"

    # Skip all replay/idle probing unless we actually need to replay a command
    if [[ $replay_flag == "--replay" && -n $grimoire_custom_command ]]; then
        pane_cmd=$(tmux list-panes -t "$popup_wid" -F "#{pane_current_command}" | head -n1)
        case "$pane_cmd" in
            bash|zsh|fish) is_idle=1 ;;
            *) is_idle=0 ;;
        esac

        if [[ $is_idle -eq 1 ]]; then
            tmux send-keys -t "$popup_wid" \
                "clear; bash -c \"${grimoire_custom_command//\"/\\\"}\"" Enter
        fi
    fi
fi

# Hook: swap by immutable window ID, restore name, kill session.
tmux set-hook -u -t "$grimoire_session" client-detached \; \
    set-hook -t "$grimoire_session" client-detached \
    "run-shell 'tmux swap-window -s \"$grimoire_wid\" -t \"$placeholder_id\"; \
        tmux rename-window -t \"$grimoire_wid\" \"$shpell_name\"; \
        tmux kill-session -t \"$grimoire_session\"'"

# --- Open popup ---
tmux \
    set-option -t "$current_session:" mouse off \; \
    display-popup \
    -E \
    -d "$session_dir" \
    -x "$grimoire_x" \
    -y "$grimoire_y" \
    -w "$grimoire_width" -h "$grimoire_height" \
    -b "rounded" \
    -S "fg=$grimoire_window_color" \
    -T "$popup_title" \
    "tmux select-window -t '$popup_wid' \; \
    attach-session -t '$grimoire_session' \; \
    run-shell 'tmux set-option -t \"$current_session:\" mouse \"$original_mouse_setting\"'"
