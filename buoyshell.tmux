#!/usr/bin/env bash
buoy_key=$(tmux show-option -gv '@buoyshell-key')
ephemeral_buoy_key=$(tmux show-option -gv '@ephemeral-buoyshell-key')
buoy_kill_key=$(tmux show-option -gv '@buoyshell-kill-key')

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
current_path=$(tmux show-environment -g PATH | cut -d= -f2-)

# Append only if not present, to prevent adding to PATH multiple times
if [[ ":$current_path:" != *":$PLUGIN_DIR/bin:"* ]]; then
  tmux set-environment -g PATH "$PLUGIN_DIR/bin:$current_path"
fi

: "${buoy_key:=f}"
: "${ephemeral_buoy_key:=F}"
: "${buoy_kill_key:=k}"

tmux bind-key "$buoy_key" run-shell "~/.tmux/plugins/tmux-buoyshell/scripts/buoy_invoke.sh standard"
tmux bind-key "$ephemeral_buoy_key" run-shell "~/.tmux/plugins/tmux-buoyshell/scripts/buoy_invoke.sh ephemeral"
tmux bind-key "$buoy_kill_key" run-shell "~/.tmux/plugins/tmux-buoyshell/scripts/buoy_invoke.sh kill"
