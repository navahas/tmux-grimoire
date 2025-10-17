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

# Resolve plugin directory for script paths
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# SINGLE-IPC OPTION FETCH: batch all tmux option reads into one display-message call
i=0
while IFS= read -r line; do
    opts[$i]="$line"
    ((i++))
done < <(tmux display-message -p '#{?@grimoire-key,#{@grimoire-key},}
#{?@ephemeral-grimoire-key,#{@ephemeral-grimoire-key},}
#{?@grimoire-kill-key,#{@grimoire-kill-key},}')

# User-configurable keybindings
# set -g @grimoire-key ''
# set -g @ephemeral-grimoire-key ''
# set -g @grimoire-kill-key ''
grimoire_key=${opts[0]}
ephemeral_grimoire_key=${opts[1]}
grimoire_kill_key=${opts[2]}

# Extend tmux PATH with plugin bin/ directory (parameter expansion avoids subprocess overhead)
env_line=$(tmux show-environment -g PATH 2>/dev/null || true)
current_path=${env_line#PATH=}
: "${current_path:=$PATH}"

# Calculate new PATH (idempotent: only append if not already present)
if [[ ":$current_path:" != *":$PLUGIN_DIR/bin:"* ]]; then
    new_path="$PLUGIN_DIR/bin:$current_path"
else
    new_path="$current_path"
fi

# Default keybindings (prefix + f/F/C/H) - overridden by user options
: "${grimoire_key:=f}"
: "${ephemeral_grimoire_key:=F}"
: "${grimoire_kill_key:=C}"
grimoire_helper_key="H"

# Batch PATH + keybindings + options to minimize
tmux \
    set-environment -g PATH "$new_path" \; \
    bind-key "$grimoire_key" "run-shell '$PLUGIN_DIR/scripts/cast_shpell.sh standard'" \; \
    bind-key "$ephemeral_grimoire_key" "run-shell '$PLUGIN_DIR/scripts/cast_shpell.sh ephemeral'" \; \
    bind-key "$grimoire_kill_key" "run-shell '$PLUGIN_DIR/scripts/cast_shpell.sh kill'" \; \
    bind-key "$grimoire_helper_key" "run-shell '$PLUGIN_DIR/scripts/cast_shpell.sh ephemeral grimoire \"$PLUGIN_DIR/bin/logo\"'" \; \
    set -g @grimoire-custom-shpell "$PLUGIN_DIR/bin/custom_shpell" \; \
    set -g @shpell-grimoire-color "#c6b7ee" \; \
    set -g @shpell-grimoire-width "45%" \; \
    set -g @shpell-grimoire-height "55%" \; \
    set -g @shpell-grimoire-position "top-center"
