#!/usr/bin/env bash

grimoire_session="_shpell-session"

custom_shpell=$1
grimoire_custom_command=$2
replay_flag=$3

grimoire_width=$(tmux show-option -gqv '@grimoire-width')
grimoire_height=$(tmux show-option -gqv '@grimoire-height')
grimoire_position=$(tmux show-option -gqv "@grimoire-position")
grimoire_window_title=$(tmux show-option -gqv '@grimoire-title')
grimoire_window_color=$(tmux show-option -gqv '@grimoire-color')

if [[ -n "$custom_shpell" ]]; then
    custom_position=$(tmux show-option -gqv "@shpell-${custom_shpell}-position" 2>/dev/null)
    custom_width=$(tmux show-option -gqv "@shpell-${custom_shpell}-width" 2>/dev/null)
    custom_height=$(tmux show-option -gqv "@shpell-${custom_shpell}-height" 2>/dev/null)
    custom_color=$(tmux show-option -gqv "@shpell-${custom_shpell}-color" 2>/dev/null)

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

# Working dir: active pane path (session) -> default-path -> $PWD
session_dir=$(
tmux display-message -p -t "${current_session:-}:" "#{pane_current_path}" 2>/dev/null \
    || tmux show-option -gqv default-path 2>/dev/null \
    || echo "$PWD"
)

# Session to operate on: client pane's session -> generic -> empty
current_session=$(
tmux display-message -p -t "${TMUX_PANE:-}" "#{session_name}" 2>/dev/null \
    || tmux display-message -p "#{session_name}" 2>/dev/null \
    || echo ""
)

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

original_mouse_setting=$(tmux show-option -gqv mouse)

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
