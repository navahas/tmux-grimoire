# BuoyShell

A tmux plugin that provides a per-session popup shell for a smoother workflow.

![Preview](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/main.png)

## Overview

BuoyShell is a minimal tmux plugin that provides "buoyant" capability to a shell window in any tmux session, enabling quick access without leaving the current workflow.

The plugin allows toggling a designated shell window within each session, making it particularly useful for terminal-based editors like Vim and Neovim, where a quick-access shell is needed without cluttering the workspace.

If you are looking for a more feature-rich floating window implementation, consider [tmux-floax](https://github.com/omerxx/tmux-floax).

### Key features of BuoyShell:

- Popup shell window per tmux session.
- Simple popup toggling with a single keybinding
- Supports moving the BuoyShell window to a custom position.

## Installation

### With Tmux Plugin Manager (TPM)

Add to `~/.tmux.conf`:
```tmux
set -g @plugin 'navahas/tmux-buoyshell'
```

Install with `prefix + I`

### Manual Installation

```bash
git clone https://github.com/navahas/tmux-buoyshell.git ~/.tmux/plugins/tmux-buoyshell
```

Add to `~/.tmux.conf`:
```tmux
run-shell ~/.tmux/plugins/tmux-buoyshell/buoyshell.tmux
```

## Usage

Press `prefix + f` to toggle the buoyant shell.

You can customize the plugin behavior by setting these options in your `~/.tmux.conf`:

```tmux
# ——————————————————————————————————————————————
# Main Options
# ——————————————————————————————————————————————
# Change the toggle keybinding (default: f)
set -g @buoyshell-key "f"

# Set buoyshell title
set-option -g @buoyshell-title ''

# Set buoyshell border color (default is empty: fallbacks to your config)
# — value: #hexcolor
set-option -g @buoyshell-color '#6C6C65'

# Set buoyshell dimensions (default: 80%)
# — value: number%
set -g @buoyshell-width "80%"
set -g @buoyshell-height "80%"

# ——————————————————————————————————————————————
# Position Presets
# ——————————————————————————————————————————————
# https://man.openbsd.org/man1/tmux.1#display-menu

# — Centered (default)
set-option -g @buoyshell-x 'C'
set-option -g @buoyshell-y 'C'

# — Middle Left
set-option -g @buoyshell-x 'P'
set-option -g @buoyshell-y 'C'
set-option -g @buoyshell-height '100%'
set-option -g @buoyshell-width '50%'

# — Middle Right
set-option -g @buoyshell-x 'W'
set-option -g @buoyshell-y 'C'
set-option -g @buoyshell-height '100%'
set-option -g @buoyshell-width '50%'

# — Top Left
set-option -g @buoyshell-x 'P'
set-option -g @buoyshell-y 'M'
 
# — Top Center
set-option -g @buoyshell-x 'C'
set-option -g @buoyshell-y 'P'
set-option -g @buoyshell-height '50%'
set-option -g @buoyshell-width '100%'
 
# — Top Right Corner
set-option -g @buoyshell-x 'W'
set-option -g @buoyshell-y 'P'
 
# — Bottom Left
set-option -g @buoyshell-x 'P'
set-option -g @buoyshell-y 'S'

# — Bottom Center
set-option -g @buoyshell-x 'C'
set-option -g @buoyshell-y 'S'
set-option -g @buoyshell-height '50%'
set-option -g @buoyshell-width '100%'

# — Bottom Right
set-option -g @buoyshell-x 'W'
set-option -g @buoyshell-y 'S'

```

My personal config, used in the main picture is the following:
```tmux
set -g @plugin 'navahas/tmux-buoyshell'
set-option -g @buoyshell-title ' buoyshell '
set-option -g @buoyshell-height '80%'
set-option -g @buoyshell-width '60%'
set-option -g @buoyshell-x 'W'
set-option -g @buoyshell-y 'S'
```

## Implementation Details

- Windows inherit parent session's working directory and state.
- If you want a specific window to become buoyant, rename it with tmux's default binding `prefix + ,` to buoyshell.

## Advanced Considerations

### Changing the Window Position

By default, BuoyShell is created as a new window getting the last available window position. If you prefer a different position, I suggest adding the following keybinds to your tmux config:

```tmux
bind -r N swap-window -t -1 \; select-window -t -1
bind -r M swap-window -t +1 \; select-window -t +1
```

This allows you to move not only BuoyShell, but any window position in your tmux session. Some users might prefer BuoyShell at the end of the window list while still being easily accessible from the toggle keybind. 

### Handling Splits

BuoyShell will display the window **including splits**. If you frequently use splits in the secondary window (which you want to act as BuoyShell), a resize with positioning is a good approach.

![Bottom Full Width](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/bottom-full.png)
![Left Full Height](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/left-full.png)

## License

MIT
