# Buoyshell - Tmux Floating Shell Manager

A tmux plugin that provides a floating shell manager with session persistence.

## Features
- Floating popup shell with session persistence
- Automatic cleanup of orphaned sessions
- Configurable appearance and behavior
- Smart session management

## Installation

### Using TPM (recommended)
Add this line to your ~/.tmux.conf:
```tmux
set -g @plugin 'cnavajas/buoyshell'
```
Press prefix + I to install.

### Manual Installation
```bash
git clone https://github.com/username/buoyshell.git ~/.tmux/plugins/buoyshell
```
Add this line to ~/.tmux.conf:
```tmux
run-shell ~/.tmux/plugins/buoyshell/buoyshell.tmux
```

## Configuration
Create `~/.config/tmux/buoyshell/config` to customize settings:
```bash
MANAGER_SESSION=_manager      # Name of the manager session
POPUP_WIDTH=80%              # Width of popup
POPUP_HEIGHT=80%             # Height of popup
POPUP_TITLE=" Shell "        # Popup title
CLEANUP_ORPHANS=true         # Automatically cleanup orphaned windows
```

## Usage
Press `prefix + f` to toggle the floating shell.
- If you're in the manager session, it will detach
- If you're in a regular session, it will open the floating shell

## License
MIT
