# BuoyShell

A Tmux plugin providing persistent floating shells per session with an easy management.

![Description](images/showcase.png)

## Overview

BuoyShell is a minimal Tmux plugin that creates a dedicated manager session for handling independent "buoyant" shells, designed to be lightweight and simple.

The plugin uses window position 1 in each tmux session as a persistent floating pane. This is where the name "BuoyShell" comes from - the shell pops up and down like a buoy, but maintains its state persistently.

If you’re looking for a more feature-rich floating window implementation, consider [tmux-floax](https://github.com/omerxx/tmux-floax).

Key features of BuoyShell:

- Independent floating shell per Tmux session with persistence
- Hidden status bar by default
- Clean session management with automatic window creation
- Simple popup toggling with a single keybinding

## Installation

### With Tmux Plugin Manager (TPM)

Add to `~/.tmux.conf`:
```tmux
set -g @plugin 'cnavajas/tmux-buoyshell'
```

Install with `prefix + I`

### Manual Installation

```bash
git clone https://github.com/cnavajas/tmux-buoyshell.git ~/.tmux/plugins/tmux-buoyshell
```

Add to `~/.tmux.conf`:
```tmux
run-shell ~/.tmux/plugins/buoyshell/buoyshell.tmux
```

## Usage

Press `prefix + f` to toggle the floating shell.

You can customize the plugin behavior by setting these options in your `~/.tmux.conf`:

```tmux
# Change the toggle keybinding (default: f)
set -g @buoyshell-key "f"

# Set popup dimensions (default: 80%)
set -g @buoyshell-width "80%"
set -g @buoyshell-height "80%"

# Set popup position
# DEFAULT -- CENTERED
set-option -g @buoyshell-x 'C'
set-option -g @buoyshell-y 'C'

# -- BOTTOM RIGHT CORNER
set-option -g @buoyshell-x 'R'
set-option -g @buoyshell-y 'S'
# -- TOP RIGHT CORNER
set-option -g @buoyshell-x 'R'
set-option -g @buoyshell-y 'M'
# -- TOP LEFT CORNER
set-option -g @buoyshell-x 'M'
set-option -g @buoyshell-y 'M'
# -- BOTTOM LEFT CORNER
set-option -g @buoyshell-x 'P'
set-option -g @buoyshell-y 'P'

# Change the manager session name (default: _buoyshell-manager)
set -g @buoyshell-session "_buoyshell-manager"
```

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
