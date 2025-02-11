#!/usr/bin/env bash
buoy_key=$(tmux show-option -gv '@buoyshell-key')
buoy_global_key=$(tmux show-option -gv '@buoyshell-global-key')
ephemeral_buoy_key=$(tmux show-option -gv '@ephemeral-buoyshell-key')
ephemeral_buoy_global_key=$(tmux show-option -gv '@ephemeral-buoyshell-global-key')

: "${buoy_key:=f}"
: "${ephemeral_buoy_key:=F}"

tmux bind-key "$buoy_key" run-shell ". ~/.tmux/plugins/tmux-buoyshell/scripts/buoy_invoke.sh standard"
tmux bind-key "$ephemeral_buoy_key" run-shell ". ~/.tmux/plugins/tmux-buoyshell/scripts/buoy_invoke.sh ephemeral"

# global key config
[[ -n $buoy_global_key ]] && tmux bind-key -n "$buoy_global_key" run-shell ". ~/.tmux/plugins/tmux-buoyshell/scripts/buoy_invoke.sh standard"
[[ -n $ephemeral_buoy_global_key ]] && tmux bind-key -n "$ephemeral_buoy_global_key" run-shell ". ~/.tmux/plugins/tmux-buoyshell/scripts/buoy_invoke.sh ephemeral"
