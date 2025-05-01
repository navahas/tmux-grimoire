![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![tmux 3.2+](https://img.shields.io/badge/tmux-3.2+-brightgreen)
![Customizable](https://img.shields.io/badge/feature-Custom_Buoys-orange)

# Tmux Grimoire

A tmux plugin for lightweight, fast, **popup shells with custom scripts** — perfect for any terminal-driven environment workflows.

![Preview](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/main.png)

### Showcase
https://github.com/user-attachments/assets/2d0f8ea0-d575-49f6-aa72-aaf2a77ebb07

## Overview

**tmux-grimoire** allows you to define and summon popup shells inside tmux, called `shpells`. These can run any command or script and are especially useful when working inside terminal-based editors like Vim/Neovim, Emacs, Helix, or Kakoune.

### Features

- Floating shell windows invoked via custom keybindings
- Support for persistent and ephemeral (disposable) shpells
- Simple, semantic positioning (e.g. `bottom-right`, `top-left`)
- Per-shpell customization of size, color, and title

---

## Installation

### With Tmux Plugin Manager (TPM)

Add to `~/.tmux.conf`:
```tmux
set -g @plugin 'navahas/tmux-grimoire'
```

Install with `prefix + I`

### Manual Installation

```bash
git clone https://github.com/navahas/tmux-grimoire.git ~/.tmux/plugins/tmux-grimoire
```

Add to `~/.tmux.conf`:
```tmux
run-shell ~/.tmux/plugins/tmux-grimoire/grimoire.tmux
```
---

## Default Usage

```bash
prefix + f    # Opens the main shpell
prefix + F    # Opens an ephemeral shpell
prefix + C    # Kills the current shpell window
```

### Quick Configuration

```tmux
set -g @plugin 'navahas/tmux-grimoire'
set-option -g @grimoire-title ' grimoire '
set-option -g @grimoire-color '' # or add some color like #dcdcaa
set-option -g @grimoire-height '80%'
set-option -g @grimoire-width '60%'
set-option -g @grimoire-position 'right'

# Custom Shpell Setup
bind-key -T prefix Q run-shell "custom_shpell standard personal-shpell"
bind-key -T prefix b run-shell "custom_shpell standard directories 'ls -la'"
bind-key -T prefix W run-shell "custom_shpell ephemeral system-monitor 'htop'"
```

You can customize the plugin behavior by setting these options in your `~/.tmux.conf`:

```tmux
# Main Options
set -g @grimoire-key "f"
set -g @ephemeral-grimoire-key "F"
set -g @grimoire-kill-key "C"

set-option -g @grimoire-title ''
set-option -g @grimoire-color '#6c6c65' # — value: '#hexcolor'
set-option -g @grimoire-width '80%' # — value: number%
set-option -g @grimoire-height '70%' # — value: number%
set-option -g @grimoire-position 'top-left'
# (@grimoire-position options)
# 'top-center'
# 'top-right'
# 'bottom-left'
# 'bottom-center'
# 'bottom-right'
# 'left'
# 'right'
# 'center' - default

# Set custom path for shpell scripts (default: $HOME/.config/grimoire)
# — value: path/to/folder
set-option -g @grimoire-path '$HOME/custom/scripts/path'

```
---

## What Is a Shpell?

A `shpell` is a popup shell window that can be configured to run any script, command, or dashboard inside your tmux session. Think of it as a summonable workspace that doesn’t disrupt your current terminal flow.

## Custom Shpells

You can bind any shell command or script to a custom key using the `custom_shpell` helper.

This is great for:
- Quickly running project-specific commands like `cargo build`, `npm run`, `pytest`, etc.
- Toggling your own dashboards, logs, monitors, or CLI tools
- Integrating personal scripts without cluttering your tmux windows

###  Binding a Custom Shpell

Use the `custom_shpell` helper like this:

```tmux
bind-key -T prefix <key> run-shell "custom_shpell <standard|ephemeral> <shpell-name> '<command>' [--replay]"
```

- `standard | ephemeral`: Choose whether the shell persists (standard) or closes after use (ephemeral).
- `shpell-name`: Your custom label (avoid spaces), e.g. `logs`, `build`, `test-log`, `unit_tests`.
- `command`: Any shell command, script path, or CLI. Leave empty for a basic popup shell.
- `--replay` (optional): Re-runs the command only if the popup is idle.

> [!IMPORTANT]
> By default, commands only run once when a custom shpell is triggered.
> To support repeated executions (e.g., running `cargo build` again), use the `--replay` flag.

_Smart Replay: If `--replay` is set, the command is only re-sent if the shell is idle, ensuring that active processes aren't interrupted._
 
> [!TIP]
> Check out the [grimoire](https://github.com/navahas/grimoire) repo for a collection of reusable scripts (shpells).

Examples:

```tmux
bind-key -T prefix E run-shell "custom_shpell standard personal-shpell"
bind-key -T prefix E run-shell "custom_shpell standard rust-build 'cargo build' --replay"
bind-key -T prefix R run-shell "custom_shpell ephemeral unit_tests '$HOME/.scripts/test_suite.sh'"
bind-key -T prefix Q run-shell "custom_shpell ephemeral test-logs 'tail -f /var/log/syslog'"
```

### Per-Shpell Customization

Each custom shpell can have its own position, size, color, and title by using per-shpell options in your `~/.tmux.conf`.

https://github.com/user-attachments/assets/d609c528-3abf-4baa-afae-4b7060768cd8

These options follow this format:

```tmux
set-option -g @shpell-<shpell-name>-color
set-option -g @shpell-<shpell-name>-position
set-option -g @shpell-<shpell-name>-width
set-option -g @shpell-<shpell-name>-height
```
> All options fallback to the global values defined with @grimoire-*.

Examples:

```tmux
bind-key -T prefix q run-shell "custom_shpell standard dev"
set-option -g @shpell-dev-color '#c2b3e9'
set-option -g @shpell-dev-position 'top-right'
set-option -g @shpell-dev-width '100%'
set-option -g @shpell-dev-height '50%'

bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""
set-option -g @shpell-gitlog-color '#d98870'
set-option -g @shpell-gitlog-position 'bottom-left'
set-option -g @shpell-gitlog-width '50%'
set-option -g @shpell-gitlog-height '100%'
```

### Recommended Keys for Custom Shpells

For custom keybindings, we recommend using rarely bound, easy-to-reach keys like:

Q, W, E, R, T, Y, U, H, M, F, G

These keys are generally unbound in tmux and offer a smooth developer workflow.

> Friendly Reminder: Uppercase bindings (like Q) require holding Shift, e.g. prefix + Shift + Q.

---

## Advanced Considerations

### Changing the Window Position

By default, shpells are created as a new window getting the last available window position. If you prefer a different position, I suggest adding the following keybinds to your tmux config:

```tmux
bind -r N swap-window -t -1 \; select-window -t -1
bind -r M swap-window -t +1 \; select-window -t +1
```

This allows you to move any window position in your tmux session. Some users might prefer specific s at the end of the window list while still being easily accessible from the toggle keybind.

### Handling Splits

Tmux-grimoire will display the window **including splits**. If you frequently use splits in the secondary window (which you want to act as a ), a resize with positioning is a good approach.

![Bottom Full Width](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/bottom-full.png)
![Left Full Height](https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/left-full.png)

---

If you are looking for a single feature-rich floating shell implementation, consider [tmux-floax](https://github.com/omerxx/tmux-floax).

## License

MIT
