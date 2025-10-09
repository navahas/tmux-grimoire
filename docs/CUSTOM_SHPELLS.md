# Custom Shpells

Create custom popup shells (`shpells`) to launch any script, CLI tool, or command with a single keybinding.

## Binding Syntax

```tmux
bind-key -T prefix <key> \
  run-shell "custom_shpell <standard|ephemeral> <shpell-name> '<command>' [--replay]"
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `standard` \| `ephemeral` | **Standard**: Persistent shell that stays open<br>**Ephemeral**: Closes automatically after command completes |
| `<shpell-name>` | Custom identifier (avoid spaces). Used for per-shpell configuration. Examples: `dev`, `build`, `test-log` |
| `'<command>'` | Shell command or script path to execute. Omit for a blank interactive shell. |
| `--replay` | (Optional) Enable smart replay for repeated executions |

## The `--replay` Flag

### Default Behavior (Without `--replay`)

By default, commands **run only once** when the shpell is first opened:

```tmux
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo build'"
```

- First press of `prefix + b`: Runs `cargo build`
- Subsequent presses of `prefix + b`: Opens the same shpell, but doesn't re-run the command

### Smart Replay (With `--replay`)

When `--replay` is enabled, the command re-executes intelligently:

```tmux
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo build' --replay"
```

- First press: Runs `cargo build`
- Subsequent presses:
  - If shell is **idle** → re-runs `cargo build`
  - If shell is **busy** → does nothing (prevents interrupting active processes)

#### When to Use `--replay`

Use `--replay` for commands you want to run repeatedly:

- Build commands (`cargo build`, `npm run build`, `make`)
- Test runners
- File watchers that you want to restart
- Status checks or reports

**Don't use `--replay`** for:

- Interactive shells (defeats the purpose)
- Long-running servers (you don't want to restart them accidentally)
- One-time setup commands

## Examples

### Basic Examples

```tmux
# Blank interactive shell named "dev"
bind-key -T prefix q run-shell "custom_shpell standard dev"

# Quick git log viewer (ephemeral)
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""

# Rust build with replay (standard)
bind-key -T prefix b run-shell "custom_shpell standard rust-build 'cargo build' --replay"

# System log tail (ephemeral)
bind-key -T prefix L run-shell "custom_shpell ephemeral syslog 'tail -f /var/log/syslog'"
```

### Script-Based Shpells

Reference scripts from your `@grimoire-path` directory:

```tmux
# Set custom scripts location (optional, default shown)
set -g @grimoire-path '$HOME/.config/grimoire'

# Run script from grimoire path
bind-key -T prefix R run-shell "custom_shpell ephemeral test 'sphell/test.sh'"

# Run script with full path
bind-key -T prefix W run-shell "custom_shpell standard my-workflow '$HOME/.config/foo/workflow.sh' --replay"
```

### Advanced Examples

```tmux
# Development notes (persistent text editor)
bind-key -T prefix E run-shell "custom_shpell standard notes 'nvim ~/dev-notes.md'"

# Docker compose logs (ephemeral)
bind-key -T prefix D run-shell "custom_shpell ephemeral docker-logs 'docker compose logs -f'"

# Python test runner with replay
bind-key -T prefix t run-shell "custom_shpell standard pytest 'pytest -v' --replay"

# NPM development server
bind-key -T prefix N run-shell "custom_shpell standard npm-dev 'npm run dev'"

# Quick project search
bind-key -T prefix S run-shell "custom_shpell ephemeral search 'rg --color=always -i'"
```

## Styling Custom Shpells

Override global appearance for specific shpells:

```tmux
# Create a custom "gitlog" shpell with unique styling
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""

set -g @shpell-gitlog-color '#e3716e'      # Red-ish border
set -g @shpell-gitlog-position 'right'     # Dock to right side
set -g @shpell-gitlog-width '50%'          # Half screen width
set -g @shpell-gitlog-height '100%'        # Full height

# Create a "dev" shpell with different styling
bind-key -T prefix q run-shell "custom_shpell standard dev"

set -g @shpell-dev-color '#c2b3e9'         # Purple border
set -g @shpell-dev-position 'top-right'    # Top right corner
set -g @shpell-dev-width '100%'            # Full width
set -g @shpell-dev-height '50%'            # Half height
```

See [CONFIGURATION.md](CONFIGURATION.md) for all styling options.

## Recommended Keybindings

These keys are generally unbound in tmux and work well for custom shpells:

**Lowercase** (no Shift needed): `q`, `w`, `e`, `r`, `t`, `y`, `u`, `h`, `m`, `f`, `g`

**Uppercase** (requires Shift): `Q`, `W`, `E`, `R`, `T`, `Y`, `U`, `H`, `M`, `F`, `G`

Note: Default grimoire bindings use `f`, `F`, and `C` (can be changed in configuration).

## Finding More Shpells

Check out the [grimoire repository](https://github.com/navahas/grimoire) for a collection of ready-to-use shpell scripts and examples.

## Troubleshooting

### Command not running on shpell open

Make sure the command is properly quoted:

```tmux
# ✓ Correct
bind-key -T prefix t run-shell "custom_shpell standard test 'npm test'"

# ✗ Incorrect (missing quotes around command)
bind-key -T prefix t run-shell "custom_shpell standard test npm test"
```

### Replay not working

- Verify the `--replay` flag is outside the command quotes:
  ```tmux
  # ✓ Correct
  "custom_shpell standard build 'cargo build' --replay"

  # ✗ Incorrect
  "custom_shpell standard build 'cargo build --replay'"
  ```

### Shpell doesn't appear

After adding bindings:
1. Reload tmux configuration: `tmux source-file ~/.tmux.conf`
2. Or restart your tmux session
