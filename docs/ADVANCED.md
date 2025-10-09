# Advanced Usage

## Working with Splits

Shpells respect existing pane splits. The popup appears relative to the active pane.

**Full-Width Bottom Panel**
```
┌─────────────────────────┐
│                         │
│    Main Editor/Code     │
│                         │
├─────────────────────────┤
│      Shpell Popup       │
│   (bottom-center 30%)   │
└─────────────────────────┘

set -g @grimoire-position 'bottom-center'
set -g @grimoire-width '100%'
set -g @grimoire-height '30%'
```

**Full-Height Side Panel**
```
┌─────────┬───────────────┐
│         │               │
│ Shpell  │     Code      │
│  Popup  │               │
│         │               │
│         │               │
└─────────┴───────────────┘

set -g @grimoire-position 'left'
set -g @grimoire-width '30%'
set -g @grimoire-height '100%'
```

## Multiple Shpells Workflow

Create a complete development environment with multiple shpells:

```tmux
# Main shell
bind-key -T prefix q run-shell "custom_shpell standard dev"
set -g @shpell-dev-position 'bottom-center'
set -g @shpell-dev-height '40%'

# Build output
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo build' --replay"
set -g @shpell-build-position 'right'
set -g @shpell-build-width '40%'

# Git log
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph\""
set -g @shpell-gitlog-position 'top-center'
```

## Lifecycle

**Standard (Persistent)** shpells:
- Stay open until closed
- Maintain state between toggles
- Use for: dev shells, build outputs, monitored logs

**Ephemeral** shpells:
- Auto-close when command completes
- Clean slate each time
- Use for: quick lookups, one-time commands, status checks

**Closing shpells**: Use `prefix + f` to toggle, or `prefix + C` to kill current shpell window.

## Color Themes

Match shpells to your terminal theme:

**Gruvbox Example**
```tmux
set -g @grimoire-color '#d65d0e'        # Gruvbox orange
set -g @shpell-dev-color '#458588'      # Gruvbox blue
set -g @shpell-build-color '#98971a'    # Gruvbox green
```

## Performance Tips

**For heavy output**, limit results:
```tmux
bind-key -T prefix L run-shell "custom_shpell ephemeral logs 'tail -n 1000 app.log'"
```

**For resource-intensive scripts**:
- Use `standard` (not `ephemeral`) to keep window alive
- Avoid `--replay` if you don't want accidental reruns

## Alternatives

Looking for something different?

- **[tmux-floax](https://github.com/omerxx/tmux-floax)** — Single feature-rich floating terminal
- **Native tmux popups** — Built-in `display-popup` for simple cases

Tmux Grimoire focuses on multiple customizable shpells with script integration and smart replay.
