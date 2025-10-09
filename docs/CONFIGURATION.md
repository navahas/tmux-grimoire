# Configuration

## Global Options

Configure the default appearance and behavior for all shpells in your `~/.tmux.conf`:

### Keybindings

```tmux
# Default keybindings (customize as needed)
set -g @grimoire-key "f"              # Opens the main shpell
set -g @ephemeral-grimoire-key "F"    # Opens an ephemeral shpell
set -g @grimoire-kill-key "C"         # Kills the current shpell window
```

### Appearance

```tmux
# Title
set -g @grimoire-title ' grimoire '   # Plain text title
set -g @grimoire-title ' 󱥭 '        # Nerd Font icon (if available)

# Color
set -g @grimoire-color '#c6b7ee'      # Border and title color (hex)

# Size
set -g @grimoire-width '80%'          # Width as percentage or exact cells
set -g @grimoire-height '30%'         # Height as percentage or exact cells

# Position
set -g @grimoire-position 'bottom-center'  # See position options below
```

### Custom Shpells Path

```tmux
# Directory for custom shpell scripts
set -g @grimoire-path '$HOME/.config/grimoire'  # default location
```

Scripts placed in this directory can be referenced by relative path in custom shpell bindings.

## Position Options

Available positions for shpells:

```
┌─────────────┬──────────────┬─────────────┐
│  top-left   │  top-center  │  top-right  │
├─────────────┼──────────────┼─────────────┤
│    left     │    center    │    right    │
├─────────────┼──────────────┼─────────────┤
│ bottom-left │bottom-center │bottom-right │
└─────────────┴──────────────┴─────────────┘
```

## Per-Shpell Configuration

Override global settings for individual shpells using the pattern `@shpell-<name>-<option>`:

```tmux
# Example: Customize a shpell named "dev"
bind-key -T prefix q run-shell "custom_shpell standard dev"

set -g @shpell-dev-color '#c2b3e9'
set -g @shpell-dev-position 'top-right'
set -g @shpell-dev-width '100%'
set -g @shpell-dev-height '50%'
```

```tmux
# Example: Customize an ephemeral shpell named "gitlog"
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""

set -g @shpell-gitlog-color '#e3716e'
set -g @shpell-gitlog-position 'right'
set -g @shpell-gitlog-width '50%'
set -g @shpell-gitlog-height '100%'
```

### Available Per-Shpell Options

```tmux
set -g @shpell-<name>-color     # Border/title color
set -g @shpell-<name>-position  # Position (see diagram above)
set -g @shpell-<name>-width     # Width (percentage or cells)
set -g @shpell-<name>-height    # Height (percentage or cells)
```

Any option not specified for a shpell will fall back to the global `@grimoire-*` value.

## Configuration Tips

1. **Test Changes Live**: After editing `~/.tmux.conf`, reload with:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

2. **Color Schemes**: Use hex colors matching your terminal theme for visual consistency

3. **Size Guidelines**:
   - For side panels: `width '50%'`, `height '100%'`
   - For bottom panels: `width '100%'`, `height '30-50%'`
   - For centered popups: `width '80%'`, `height '70%'`

4. **Shpell Names**: Use descriptive names without spaces (use hyphens or underscores)
