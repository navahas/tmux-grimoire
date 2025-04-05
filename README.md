![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![tmux 3.2+](https://img.shields.io/badge/tmux-3.2+-brightgreen)
![Customizable](https://img.shields.io/badge/feature-Custom_Buoys-orange)

# BuoyShell

A tmux plugin for lightweight, fast, **popup shells with custom scripts** — perfect for any terminal-driven environment workflows.

![Preview](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/main.png)

### Showcase
https://github.com/user-attachments/assets/2d0f8ea0-d575-49f6-aa72-aaf2a77ebb07

## Overview

BuoyShell is a minimal tmux plugin that provides "buoyant" capability to shell windows in any tmux session, enabling quick access without leaving the current workflow.

The plugin allows toggling designated shell windows within each session, making it particularly useful for terminal-based editors like Vim/Neovim, Emacs, Helix, Kakoune... where a quick-access shell is needed without cluttering the workspace.

### Features

- Toggle popup shell windows per tmux session using custom keybindings  
- Customize the position, size, color, and title of your BuoyShell popup  
- Create custom BuoyShell popups with your own commands or scripts

---

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
---

## Usage

Press `prefix + f` to toggle the **main BuoyShell** popup (enabled by default).

You can toggle **any buoy on or off** — either the default one (`prefix + f`) or any custom one you've created. Pressing the same key again will close the popup.

### Quick Configuration

```tmux
set -g @plugin 'navahas/tmux-buoyshell'
set-option -g @buoyshell-title ' buoyshell '
set-option -g @buoyshell-color '' # or add some color like #dcdcaa
set-option -g @buoyshell-height '80%'
set-option -g @buoyshell-width '60%'
set-option -g @buoyshell-x 'W'
set-option -g @buoyshell-y 'S'

# Custom Buoy Setup
bind-key -T prefix Q run-shell "custom_buoy standard personal-buoy"
bind-key -T prefix b run-shell "custom_buoy standard directories 'ls -la'"
bind-key -T prefix W run-shell "custom_buoy ephemeral system-monitor 'htop'"
```

You can customize the plugin behavior by setting these options in your `~/.tmux.conf`:

```tmux
# ——————————————————————————————————————————————
# Main Options
# ——————————————————————————————————————————————
# Change the toggle keybinding (default: f)
set -g @buoyshell-key "f"
# Change the ephemeral buoyshell keybinding (default: F)
set -g @ephemeral-buoyshell-key "F"

# Set buoyshell title
set-option -g @buoyshell-title ''

# Set buoyshell border color (default is empty: fallbacks to your config)
# — value: #hexcolor
set-option -g @buoyshell-color '#6c6c65'

# Set buoyshell dimensions (default: 80%)
# — value: number%
set -g @buoyshell-width "80%"
set -g @buoyshell-height "80%"

# Set custom path for buoy scripts (default: $HOME/.config/custom-buoys)
# — value: path/to/folder
set-option -g @buoyshell-buoyspath '$HOME/custom/scripts/path'

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
---

## Custom Buoys

BuoyShell supports **user-defined custom buoys** via simple keybindings that launch your own scripts or commands — in either `standard` or `ephemeral` mode.

This is great for:
- Quickly running project-specific commands like `cargo build`, `npm run`, `pytest`, etc.
- Toggling your own dashboards, logs, monitors, or CLI tools
- Integrating personal scripts without cluttering your tmux windows

###  Binding a Custom Buoy

Use the `custom_buoy` helper like this:

```tmux
bind-key -T prefix <key> run-shell "custom_buoy <standard|ephemeral> <buoy-name> '<command>' [--replay]"
```

- `standard | ephemeral`: Choose whether the shell persists (standard) or closes after use (ephemeral).
- `buoy-name`: Your custom label (avoid spaces), e.g. `logs`, `build`, `test-log`, `unit_tests`.
- `command`: Any shell command, script path, or CLI. Leave empty for a basic popup shell.
- `--replay` (optional): Only re-run the command if the shell is idle.

> [!IMPORTANT] 
> By default, commands only run once when a custom Buoy is triggered.
> To support repeated executions (e.g., running `cargo build` again), use the `--replay` flag.

_Smart Replay: If `--replay` is set, the command is only re-sent if the shell is idle, ensuring that active processes aren't interrupted._
 
> [!TIP]
> Check out the [custom-buoys](https://github.com/navahas/custom-buoys) repo for a collection of reusable scripts.

Examples:

```tmux
bind-key -T prefix E run-shell "custom_buoy standard personal-buoy"
bind-key -T prefix E run-shell "custom_buoy standard rust-build 'cargo build' --replay"
bind-key -T prefix R run-shell "custom_buoy ephemeral unit_tests '$HOME/.scripts/test_suite.sh'"
bind-key -T prefix Q run-shell "custom_buoy ephemeral test-logs 'tail -f /var/log/syslog'"

```

### Appearance Customization

Each custom buoy can have its own position, size, color, and title by using per-buoy options in your `~/.tmux.conf`.

https://github.com/user-attachments/assets/d609c528-3abf-4baa-afae-4b7060768cd8

These options follow this format:

```tmux
set-option -g @buoy-<buoy-name>-color
set-option -g @buoy-<buoy-name>-x
set-option -g @buoy-<buoy-name>-y
set-option -g @buoy-<buoy-name>-width
set-option -g @buoy-<buoy-name>-height
```
> If no specific values are provided, BuoyShell will fall back to the global options.

Examples:

```tmux
bind-key -T prefix q run-shell "custom_buoy standard dev"
set-option -g @buoy-dev-color '#c2b3e9'
set-option -g @buoy-dev-x 'C'
set-option -g @buoy-dev-y 'S'
set-option -g @buoy-dev-width '100%'
set-option -g @buoy-dev-height '50%'

bind-key -T prefix G run-shell "custom_buoy ephemeral gitlog \"git log --oneline --graph --decorate --all\""
set-option -g @buoy-gitlog-color '#d98870'
set-option -g @buoy-gitlog-x 'W'
set-option -g @buoy-gitlog-y 'C'
set-option -g @buoy-gitlog-width '50%'
set-option -g @buoy-gitlog-height '100%'
```

### Recommended Keys for Custom Buoys

For custom keybindings, we recommend using rarely bound, easy-to-reach keys like:

Q, W, E, R, T, Y, U, H, M, F, G

These keys are generally unbound in tmux and offer a smooth developer workflow.

> Friendly Reminder: Uppercase bindings (like Q) require holding Shift, e.g. prefix + Shift + Q.

---

## Advanced Considerations

### Implementation Details

- Windows inherit parent session's working directory and state.
- Use `prefix + ,` to rename any window to `buoyshell` if you wish to make it the main BuoyShell.

### Changing the Window Position

By default, BuoyShells are created as a new window getting the last available window position. If you prefer a different position, I suggest adding the following keybinds to your tmux config:

```tmux
bind -r N swap-window -t -1 \; select-window -t -1
bind -r M swap-window -t +1 \; select-window -t +1
```

This allows you to move not only BuoyShell, but any window position in your tmux session. Some users might prefer BuoyShell at the end of the window list while still being easily accessible from the toggle keybind. 

### Handling Splits

BuoyShell will display the window **including splits**. If you frequently use splits in the secondary window (which you want to act as BuoyShell), a resize with positioning is a good approach.

![Bottom Full Width](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/bottom-full.png)
![Left Full Height](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/left-full.png)

---

If you are looking for a single feature-rich floating shell implementation, consider [tmux-floax](https://github.com/omerxx/tmux-floax).

## License

MIT
