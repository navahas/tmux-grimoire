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
| `<shpell-name>` | Custom identifier (avoid spaces). Used for per-shpell configuration.<br>Examples: `dev`, `build_gcc`, `test-log` |
| `'<command>'` | Shell command or script path to execute. Omit for a blank interactive shell. |
| `--replay` | [Optional] Enable smart replay for repeated executions |

## `--replay`

The `--replay` flag re-runs a command inside an existing shpell intelligently.

### Default Behavior > no `--replay`
Commands run only on the first invocation:

```tmux
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo build'"
```

- First press of `prefix + b`: Runs `cargo build`
- Subsequent presses: Opens the same shpell, but doesn't re-run the command

### With `--replay`
Command re-runs automatically (only if the shell is idle):

```tmux
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo run' --replay"
```
- First press: Runs `cargo build`
- Subsequent presses:
  - If shell is **idle** -> re-runs the command
  - If shell is **busy** -> skips (avoids disrupting active processes)

**Use `--replay` for:** build commands, test runners, file watchers, status commands

**Avoid it for:** interactive shells, servers, or long-running sessions

---
## Examples

### Basic

```tmux
# Blank interactive shell
bind-key -T prefix q run-shell "custom_shpell standard dev"

# Git log viewer (ephemeral)
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""

# Build with replay
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo build' --replay"

# Test runner with replay
bind-key -T prefix t run-shell "custom_shpell standard test 'npm test' --replay"
```

### Script-Based

```tmux
# Set custom scripts location (optional)
set -g @grimoire-path '$HOME/.config/grimoire'

# Run script from grimoire path
bind-key -T prefix R run-shell "custom_shpell ephemeral test 'scripts/test.sh'"

# Run script with full path
bind-key -T prefix W run-shell "custom_shpell standard workflow '$HOME/.config/foo/bar.sh' --replay"
```

### Advanced

```tmux
# Development notes
bind-key -T prefix E run-shell "custom_shpell standard notes 'nvim ~/notes.md'"

# Docker logs
bind-key -T prefix D run-shell "custom_shpell ephemeral logs 'docker compose logs -f'"

# Quick search
bind-key -T prefix S run-shell "custom_shpell ephemeral search 'rg --color=always -i'"
```
---
## Custom Shpell Styling

Override global appearance for specific shpells:

```tmux
# Customize "gitlog" shpell
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph\""
set -g @shpell-gitlog-color '#e3716e'
set -g @shpell-gitlog-position 'right'
set -g @shpell-gitlog-width '50%'
set -g @shpell-gitlog-height '100%'
```

See [CONFIGURATION.md](CONFIGURATION.md) for all styling options.

## Troubleshooting

<details>
<summary><strong>Command not running?</strong></summary>
Ensure the command is properly quoted:

```tmux
custom_shpell standard test 'npm test'
````

</details>

<details>
<summary><strong>Replay not working?</strong></summary>

Verify `--replay` is **outside** the command quotes:

Correct:

```tmux
custom_shpell standard build 'cargo build' --replay
```

Incorrect:

```tmux
custom_shpell standard build 'cargo build --replay'
```

</details>

<details>
<summary><strong>Shpell doesn’t appear?</strong></summary>

Reload tmux or restart your session:

```bash
tmux source-file ~/.tmux.conf
```

</details>

---
**More examples**: Check the [grimoire repository](https://github.com/navahas/grimoire) for ready-to-use shpell scripts.
(WIP)
