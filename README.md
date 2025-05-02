![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![tmux 3.2+](https://img.shields.io/badge/tmux-3.2+-brightgreen)

# Tmux Grimoire

A lightweight tmux plugin for summonable popup shells, aka `shpells`, driven by custom scripts.

![Preview](https://raw.githubusercontent.com/navahas/tmux-grimoire/assets/images/grimoire.png)

---
## Quickstart

Install with TPM:
```tmux
set -g @plugin 'navahas/tmux-grimoire'
```
Press `prefix + I` to install.
> **Note:** If you’d rather install manually, see [Manual Installation](#manual-installation) below.

### Minimal config to get started:

```tmux
# Enable plugin
set -g @plugin 'navahas/tmux-grimoire'

# Global appearance
set -g @grimoire-title   ' grimoire '
set -g @grimoire-color   '#c6b7ee'
# Optional overrides:
# set -g @grimoire-width  '80%'
# set -g @grimoire-height '30%'
# set -g @grimoire-position 'bottom-center'

# Custom shpells
bind-key -T prefix q run-shell "custom_shpell standard dev"
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""
set -g @shpell-gitlog-color    '#e3716e'
set -g @shpell-gitlog-position 'right'
set -g @shpell-gitlog-width    '50%'
set -g @shpell-gitlog-height   '100%'
```
Now hit:
- `prefix + q` —> your dev shell
- `prefix + G` —> ephemeral gitlog shell

#### Default keybinds:
```bash
prefix + f    # Opens the main shpell
prefix + F    # Opens an ephemeral shpell
prefix + C    # Kills the current shpell window
```
---

#### Manual Installation

```bash
git clone https://github.com/navahas/tmux-grimoire.git ~/.tmux/plugins/tmux-grimoire
```
Add to `~/.tmux.conf`:
```tmux
run-shell ~/.tmux/plugins/tmux-grimoire/grimoire.tmux
```
---

## Configuration

### Global Options

```tmux
# Keybindings (defaults: f, F, C)
set -g @grimoire-key "f"
set -g @ephemeral-grimoire-key "F"
set -g @grimoire-kill-key "C"

# Appearance
set -g @grimoire-title ' 󱥭 ' # If you have a nerdfont to use icons
set -g @grimoire-color '#6c6c65'
set -g @grimoire-width '80%'
set -g @grimoire-height '70%'
set -g @grimoire-position 'center'

# Custom shpells path
set -g @grimoire-path '$HOME/.config/grimoire' # default location
```

#### Position Options
```bash
top-left    | top-center    | top-right
bottom-left | bottom-center | bottom-right
left        | right         | center
```
---

## Custom Shpells

Create custom popup shells (`shpells`) to launch any script, CLI tool, or command.

### Binding Syntax

```tmux
bind-key -T prefix <key> \
  run-shell "custom_shpell <standard|ephemeral> <shpell-name> '<command>' [--replay]"
```
- `standard | ephemeral`: Choose either a persistent shell (standard) or close after use (ephemeral).
- `shpell-name`: Custom label identifier (avoid spaces), e.g. `logs`, `build`, `test-log`, `unit_tests`.
- `command`: Shell command or script path to be executed; omit for a blank shell.
- `--replay` (optional): re-run only when idle (for tasks like builds).

> [!IMPORTANT]
> By default, commands only run once when a custom shpell is triggered.
> To support repeated executions (e.g., running `cargo build` again), use the `--replay` flag.

_Smart Replay: If `--replay` is set, the command is only re-sent if the shell is idle, ensuring that active processes aren't interrupted._
 
> [!TIP]
> Check out the [grimoire](https://github.com/navahas/grimoire) repo for a collection of reusable scripts (shpells).

Bindings Examples:
```tmux
bind-key -T prefix E run-shell "custom_shpell standard personal-shpell"
bind-key -T prefix b run-shell "custom_shpell standard rust-build 'cargo build' --replay"
# Using the scripts inside @grimoire-path '$HOME/.config/grimoire'
bind-key -T prefix R run-shell "custom_shpell ephemeral test 'sphell/test.sh'"
bind-key -T prefix Q run-shell "custom_shpell ephemeral test-logs 'tail -f /var/log/syslog'"
```

### Per-Shpell Options

Override size, color, title, position per shpell.
```tmux
set -g @shpell-<shpell-name>-color
set -g @shpell-<shpell-name>-position
set -g @shpell-<shpell-name>-width
set -g @shpell-<shpell-name>-height
```
> All unspecified fallback to global @grimoire-* values.

Examples:
```tmux
# shpell-name: dev
bind-key -T prefix q run-shell "custom_shpell standard dev"
set -g @shpell-dev-color '#c2b3e9'
set -g @shpell-dev-position 'top-right'
set -g @shpell-dev-width '100%'
set -g @shpell-dev-height '50%'

# shpell-name: gitlog
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""
set -g @shpell-gitlog-color '#d98870'
set -g @shpell-gitlog-position 'bottom-left'
set -g @shpell-gitlog-width '50%'
set -g @shpell-gitlog-height '100%'
```

#### Recommended Keys for Custom Shpells

`Q, W, E, R, T, Y, U, H, M, F, G`

These keys are generally unbound in tmux and offer a smooth developer workflow.
> Friendly Reminder: Uppercase bindings (like Q) require holding Shift, e.g. prefix + Shift + Q.

---

## Advanced

### Window Position

The following bind allows to move windows within your tmux session.
```tmux
bind -r N swap-window -t -1 \; select-window -t -1
bind -r M swap-window -t +1 \; select-window -t +1
```

### Splits Support

Shpells respect existing splits. For best layouts, explicitly size/position or use full-width examples:

<p align="center">
  <img src="https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/bottom.png" width="400"/>
  <img src="https://raw.githubusercontent.com/navahas/tmux-buoyshell/assets/images/left.png" width="400"/>
</p>

---

#### Alternative
If you are looking for a single feature-rich floating shell implementation, consider [tmux-floax](https://github.com/omerxx/tmux-floax).

## License

MIT
