# BuoyShell

A Tmux plugin providing persistent floating shells per session with automatic management.

## Overview

BuoyShell creates a dedicated manager session that handles independent floating shells for each Tmux session. Key features:

- Independent floating shell per Tmux session with persistence
- Hidden status bar by default
- Clean session management with automatic window creation/cleanup
- Simple popup toggling with a single keybinding

## Installation

### With Tmux Plugin Manager (TPM)

Add to `~/.tmux.conf`:
```tmux
set -g @plugin 'cnavajas/buoyshell'
```

Install with `prefix + I`

### Manual Installation

```bash
git clone https://github.com/cnavajas/buoyshell.git ~/.tmux/plugins/buoyshell
```

Add to `~/.tmux.conf`:
```tmux
run-shell ~/.tmux/plugins/buoyshell/buoyshell.tmux
```

## Usage

Press `prefix + f` to toggle the floating shell.

The plugin will:
1. Create a hidden manager session if it doesn't exist
2. Create a dedicated window for your current session if needed
3. Show the shell in a centered popup

When you exit the popup, your shell state persists in the manager session.

## Implementation Details

- Manager session name: `_buoyshell-manager`
- No status bar displayed
- Popup dimensions: 80% width, 80% height
- Windows named after their parent sessions
- Windows inherit parent session's working directory

## Upcoming Features

- Customizable popup dimensions
- Configurable keybindings
- Status bar toggle option
- Session cleanup options

## License

MIT
