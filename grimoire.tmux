#!/usr/bin/env bash

: <<'TMUX_GRIMOIRE'

   ╔═══════════════════════════════════════════════════════════════╗
   ║                                                               ║
   ║  ████████╗███╗   ███╗██╗   ██╗██╗   ██╗                       ║
   ║  ╚══██╔══╝████╗ ████║██║   ██║ ██╗ ██╔╝                       ║
   ║     ██║   ██╔████╔██║██║   ██║  ████╔╝                        ║
   ║     ██║   ██║╚██╔╝██║██║   ██║ ██╔═██╗                        ║
   ║     ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝  ██╗                       ║
   ║     ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝   ╚═╝                       ║
   ║                                                               ║
   ║   ██████╗ ██████╗ ██╗███╗   ███╗ ██████╗ ██╗██████╗ ███████╗  ║
   ║  ██╔════╝ ██╔══██╗██║████╗ ████║██╔═══██╗██║██╔══██╗██╔════╝  ║
   ║  ██║  ███╗██████╔╝██║██╔████╔██║██║   ██║██║██████╔╝█████╗    ║
   ║  ██║   ██║██╔══██╗██║██║╚██╔╝██║██║   ██║██║██╔══██╗██╔══╝    ║
   ║  ╚██████╔╝██║  ██║██║██║ ╚═╝ ██║╚██████╔╝██║██║  ██║███████╗  ║
   ║   ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝  ║
   ║                                                               ║ 
   ╚═══════════════════════════════════════════════════════════════╝

   Bash trick: Using : (no-op) with heredoc creates a comment block
   that bash parses but doesn't execute - perfect for ASCII art

TMUX_GRIMOIRE

# User-configurable keybindings 
# set -g @grimoire-key '' 
# set -g @ephemeral-grimoire-key ''
# set -g @grimoire-kill-key ''
grimoire_key=$(tmux show-option -gqv '@grimoire-key')
ephemeral_grimoire_key=$(tmux show-option -gqv '@ephemeral-grimoire-key')
grimoire_kill_key=$(tmux show-option -gqv '@grimoire-kill-key')

# Resolve plugin directory for script paths
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Extend tmux PATH with plugin bin/ directory (parameter expansion avoids subprocess overhead)
env_line=$(tmux show-environment -g PATH 2>/dev/null || true)
current_path=${env_line#PATH=}
: "${current_path:=$PATH}"

# Idempotent PATH update: only append if not already present
if [[ ":$current_path:" != *":$PLUGIN_DIR/bin:"* ]]; then
    tmux set-environment -g PATH "$PLUGIN_DIR/bin:$current_path" 2>/dev/null
fi

# Default keybindings (prefix + f/F/C/H) - overridden by user options
: "${grimoire_key:=f}"
: "${ephemeral_grimoire_key:=F}"
: "${grimoire_kill_key:=C}"
grimoire_helper_key="H"

# Batch keybindings and options via heredoc to minimize tmux server calls
# Wrapped in command group with || true to prevent TPM source failures (returns exit 0 even if tmux server unavailable)
{ tmux <<TMUX
    bind-key "$grimoire_key" run-shell "$PLUGIN_DIR/scripts/cast_shpell.sh standard"
    bind-key "$ephemeral_grimoire_key" run-shell "$PLUGIN_DIR/scripts/cast_shpell.sh
    ephemeral"
    bind-key "$grimoire_kill_key" run-shell "$PLUGIN_DIR/scripts/cast_shpell.sh kill"
    bind-key "$grimoire_helper_key" run-shell "$PLUGIN_DIR/scripts/cast_shpell.sh
    ephemeral grimoire '$PLUGIN_DIR/bin/logo'"
    set -g @shpell-grimoire-color "#c6b7ee"
    set -g @shpell-grimoire-width "45%"
    set -g @shpell-grimoire-height "55%"
    set -g @shpell-grimoire-position "top-center"
TMUX
} 2>/dev/null || true
