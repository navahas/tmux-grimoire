#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux setenv -g BUOYSHELL_KEY "$(tmux show-option -gv "@buoyshell-key" || echo "f")"
tmux setenv -g BUOYSHELL_MANAGER "$(tmux show-option -gv "@buoyshell-manager" || echo "_buoyshell-manager")"
tmux setenv -g BUOYSHELL_WIDTH "$(tmux show-option -gv "@buoyshell-width" || echo "80%")"
tmux setenv -g BUOYSHELL_HEIGHT "$(tmux show-option -gv "@buoyshell-height" || echo "80%")"
tmux setenv -g BUOYSHELL_TITLE "$(tmux show-option -gv "@buoyshell-title" || echo " session: #{session_name} ")"

tmux bind-key f if-shell -F "#{==:#{client_session},_buoyshell-manager}" \
    "detach-client" \
    "run-shell '$CURRENT_DIR/scripts/buoy.sh'"
