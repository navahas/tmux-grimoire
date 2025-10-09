# Advanced Usage

## Window Management

### Swapping Window Positions

Move shpell windows within your tmux session:

```tmux
# Move current window left
bind -r N swap-window -t -1 \; select-window -t -1

# Move current window right
bind -r M swap-window -t +1 \; select-window -t +1
```

The `-r` flag allows repeating the command without pressing prefix again.

## Working with Tmux Splits

Shpells respect existing pane splits. The popup will appear relative to the active pane.

### Best Practices for Split Layouts

For optimal visual experience with splits:

**Full-Width Bottom Panel**
```tmux
set -g @grimoire-position 'bottom-center'
set -g @grimoire-width '100%'
set -g @grimoire-height '30%'
```

**Full-Height Side Panel**
```tmux
set -g @grimoire-position 'right'
set -g @grimoire-width '50%'
set -g @grimoire-height '100%'
```

**Centered Popup (works well with any split)**
```tmux
set -g @grimoire-position 'center'
set -g @grimoire-width '80%'
set -g @grimoire-height '70%'
```

### Example Split Layouts

Bottom panel with horizontal splits:

```
┌─────────────────────────┐
│                         │
│    Main Editor/Code     │
│                         │
├─────────────────────────┤
│      Shpell Popup       │
│   (bottom-center 30%)   │
└─────────────────────────┘
```

Side panel with vertical splits:

```
┌──────────────┬──────────┐
│              │          │
│     Code     │  Shpell  │
│              │  Popup   │
│              │ (right)  │
│              │          │
└──────────────┴──────────┘
```

## Multiple Shpells Workflow

Create a complete development environment with multiple shpells:

```tmux
# Main development shell
bind-key -T prefix q run-shell "custom_shpell standard dev"
set -g @shpell-dev-position 'bottom-center'
set -g @shpell-dev-height '40%'

# Build output
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo build' --replay"
set -g @shpell-build-position 'right'
set -g @shpell-build-width '40%'

# Git log viewer
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""
set -g @shpell-gitlog-position 'top-center'
set -g @shpell-gitlog-height '30%'

# Test runner
bind-key -T prefix t run-shell "custom_shpell standard tests 'npm test -- --watch' --replay"
set -g @shpell-tests-position 'bottom-left'
```

Each shpell can be toggled independently, allowing you to compose your ideal workspace.

## Shpell Lifecycle Management

### Persistent vs Ephemeral

**Standard (Persistent)** shpells:
- Remain open until explicitly closed
- Maintain state between toggles
- Good for: development shells, build outputs, logs you monitor

**Ephemeral** shpells:
- Close automatically when command completes
- Clean slate on each invocation
- Good for: quick lookups, one-time commands, status checks

### Closing Shpells

```tmux
# Default: prefix + f (toggles main shpell on/off)
# Or:     prefix + C (kills current shpell window)
```

You can also close any shpell by using its original toggle keybinding again.

## Color Schemes

Coordinate shpell colors with your terminal theme:

### Example: Nord Theme

```tmux
set -g @grimoire-color '#88c0d0'          # Nord frost blue
set -g @shpell-dev-color '#a3be8c'        # Nord green
set -g @shpell-build-color '#ebcb8b'      # Nord yellow
set -g @shpell-gitlog-color '#bf616a'     # Nord red
```

### Example: Gruvbox Theme

```tmux
set -g @grimoire-color '#d65d0e'          # Gruvbox orange
set -g @shpell-dev-color '#458588'        # Gruvbox blue
set -g @shpell-tests-color '#98971a'      # Gruvbox green
```

## Integration with Other Tools

### With tmux-resurrect

Shpells work alongside tmux-resurrect. However, popup states are not saved. After restoration:
1. Reload your tmux configuration
2. Manually reopen needed shpells

### With tmux-continuum

Similar to resurrect, continuum will restore your session but not popup states.

### With Other Popup Plugins

If you use other popup-based plugins (like tmux-floax), be aware:
- Shpells are independent windows, not panes
- Each popup can have its own configuration
- Keybindings should not conflict

## Performance Considerations

### Large Command Outputs

For commands with heavy output, consider:

```tmux
# Add output limiting
bind-key -T prefix L run-shell "custom_shpell ephemeral logs 'tail -n 1000 app.log'"

# Or use a pager
bind-key -T prefix L run-shell "custom_shpell ephemeral logs 'tail -n 1000 app.log | less'"
```

### Resource-Intensive Scripts

For long-running or resource-intensive scripts:

1. Use `standard` (not `ephemeral`) to keep the window alive
2. Avoid `--replay` if you don't want accidental reruns
3. Consider monitoring system resources within the shpell

## Alternatives

If you're looking for different features:

- **[tmux-floax](https://github.com/omerxx/tmux-floax)**: Single feature-rich floating terminal with different design goals
- **Native tmux popups**: Built-in `display-popup` command for simple use cases

Tmux Grimoire focuses on multiple customizable shpells with script integration and smart replay functionality.
