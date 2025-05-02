#!/usr/bin/env bash
grimoire_key=$(tmux show-option -gv '@grimoire-key')
ephemeral_grimoire_key=$(tmux show-option -gv '@ephemeral-grimoire-key')
grimoire_kill_key=$(tmux show-option -gv '@grimoire-kill-key')

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
current_path=$(tmux show-environment -g PATH | cut -d= -f2-)

# Append only if not present, to prevent adding to PATH multiple times
if [[ ":$current_path:" != *":$PLUGIN_DIR/bin:"* ]]; then
  tmux set-environment -g PATH "$PLUGIN_DIR/bin:$current_path"
fi

: "${grimoire_key:=f}"
: "${ephemeral_grimoire_key:=F}"
: "${grimoire_kill_key:=C}"
grimoire_helper_key="H"

tmux bind-key "$grimoire_key" run-shell "$HOME/.tmux/plugins/tmux-grimoire/scripts/cast_shpell.sh standard"
tmux bind-key "$ephemeral_grimoire_key" run-shell "$HOME/.tmux/plugins/tmux-grimoire/scripts/cast_shpell.sh ephemeral"
tmux bind-key "$grimoire_kill_key" run-shell "$HOME/.tmux/plugins/tmux-grimoire/scripts/cast_shpell.sh kill"

tmux bind-key "$grimoire_helper_key" \
  run-shell "$HOME/.tmux/plugins/tmux-grimoire/scripts/cast_shpell.sh ephemeral grimoire '$HOME/.tmux/plugins/tmux-grimoire/bin/logo'"

tmux set -g @shpell-grimoire-color "#c6b7ee"
tmux set -g @shpell-grimoire-width "45%"
tmux set -g @shpell-grimoire-height "55%"
tmux set -g @shpell-grimoire-position "top-center"
