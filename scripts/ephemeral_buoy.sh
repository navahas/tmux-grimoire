#!/usr/bin/env bash
# Cache tmux commands to reduce subprocesses
read -r current_session current_client original_mouse_setting < <(tmux display-message -p '#{client_session} #{client_name}' ; tmux show-option -gv mouse)
width=$(tmux show-option -gv '@buoyshell-width')
height=$(tmux show-option -gv '@buoyshell-height')
buoyshell_x=$(tmux show-option -gv '@buoyshell-x')
buoyshell_y=$(tmux show-option -gv '@buoyshell-y')
buoyshell_window_title=$(tmux show-option -gv '@buoyshell-title')
buoyshell_window_color=$(tmux show-option -gv '@buoyshell-color')

buoyshell_session="_ephemeral-buoy-session"
temp_window="_tty"
custom_buoy=$1
buoyshell_custom_command=$2

# Get custom settings if custom_buoy is provided
if [[ -n "$custom_buoy" ]]; then
    custom_width=$(tmux show-option -gv "@buoy-${custom_buoy}-width" 2>/dev/null)
    custom_height=$(tmux show-option -gv "@buoy-${custom_buoy}-height" 2>/dev/null)
    custom_x=$(tmux show-option -gv "@buoy-${custom_buoy}-x" 2>/dev/null)
    custom_y=$(tmux show-option -gv "@buoy-${custom_buoy}-y" 2>/dev/null)
    custom_color=$(tmux show-option -gv "@buoy-${custom_buoy}-color" 2>/dev/null)
    custom_title=$(tmux show-option -gv "@buoy-${custom_buoy}-title" 2>/dev/null)
    
    # Apply custom settings if they exist
    [[ -n "$custom_width" ]] && width="$custom_width"
    [[ -n "$custom_height" ]] && height="$custom_height"
    [[ -n "$custom_x" ]] && buoyshell_x="$custom_x"
    [[ -n "$custom_y" ]] && buoyshell_y="$custom_y"
    [[ -n "$custom_color" ]] && buoyshell_window_color="$custom_color"
    [[ -n "$custom_title" ]] && buoyshell_window_title="$custom_title"
fi

# Set default values if not specified
: "${width:=80%}"
: "${height:=80%}"
: "${buoyshell_x:=C}"
: "${buoyshell_y:=C}"
: "${buoyshell_window_title:=}"
: "${buoyshell_window_color:=}"

# Set popup title
popup_title="${buoyshell_window_title}"
[[ -n $custom_buoy ]] && popup_title="${popup_title:+$popup_title|} $custom_buoy "

# Create buoyshell session if it doesn't exist
if ! tmux has-session -t "$buoyshell_session" 2>/dev/null; then
    TMUX='' tmux new-session -d -s "$buoyshell_session" -n "$temp_window"
    tmux set-option -t "$buoyshell_session" status off
fi

# Set hook to kill window when detached
tmux set-hook -t "$buoyshell_session" client-detached \
    "run-shell 'tmux kill-window -t \"$current_session\"'"

session_dir=$(tmux display-message -t "$current_session" -p '#{pane_current_path}')

window_exists=$(tmux list-windows -t "$buoyshell_session" -F "#{window_name}" | grep -x "$current_session" || echo "")

# Create window if it doesn't exist
if [[ -z "$window_exists" ]]; then
    tmux new-window -d -t "$buoyshell_session" -n "$current_session" -c "$session_dir"
    if [[ -n $buoyshell_custom_command ]]; then
        tmux send-keys -t "$buoyshell_session:$current_session" "tput clear; bash -c \"${buoyshell_custom_command//\"/\\\"}\"" Enter
    fi
fi

# Clean up temp window
tmux kill-window -t "$buoyshell_session:$temp_window" 2>/dev/null || true

# Disable mouse before displaying popup
tmux set-option -g mouse off

# Display popup
tmux display-popup \
    -E \
    -d "$session_dir" \
    -x "$buoyshell_x" \
    -y "$buoyshell_y" \
    -w "$width" -h "$height" \
    -b "rounded" \
    -S "fg=$buoyshell_window_color" \
    -T "$popup_title" \
    "tmux attach-session -t '$buoyshell_session' \; select-window -t '$current_session'"

# Restore original mouse setting
tmux set-option -g mouse "$original_mouse_setting"
