![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![tmux 3.2+](https://img.shields.io/badge/tmux-3.2+-brightgreen)

# Tmux Grimoire

Summonable popup shells (`shpells`) for tmux: customizable, scriptable and driven by keybindings.

<p align="center">
    <img src="https://raw.githubusercontent.com/navahas/tmux-grimoire/assets/images/grimoire.png"
        alt="preview_tmux_grimoire" width="500"/>
</p>

--- 

## Installation

Run the interactive installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/navahas/tmux-grimoire/main/install.sh)
```

The script will detect your setup, configure keybindings, and add example shpells to `~/.tmux.conf`.

**Prefer manual setup?** See [docs/INSTALLATION.md](docs/INSTALLATION.md#manual-installation)

## Quick Reference

Default keybindings:

| Keybind | Action |
|---------|--------|
| `prefix + f` | Toggle the main shpell (open/close) |
| `prefix + F` | Summon a new ephemeral shpell |
| `prefix + C` | Close and dismiss the current shpell |
| `prefix + H` | Reveal the Grimoire welcome banner |

## What's Next?

After installation, your `~/.tmux.conf` will include example custom shpells, commented out and ready to awaken.
Uncomment a few, tweak them and shape your workflow.

**Further Reading:**
- **[Custom Shpells](docs/CUSTOM_SHPELLS.md)** — Create custom keybindings and learn the `--replay` trick
- **[Configuration](docs/CONFIGURATION.md)** — Adjust colors, size and position
- **[Advanced Usage](docs/ADVANCED.md)** — Manage windows, splits and integrations

## Quick Example

```tmux
# Add to ~/.tmux.conf

# Custom dev shell
bind-key -T prefix q run-shell "custom_shpell standard dev"

# Git log viewer (ephemeral, custom styling)
bind-key -T prefix G run-shell "custom_shpell ephemeral gitlog \"git log --oneline --graph --decorate --all\""
set -g @shpell-gitlog-color '#e3716e'
set -g @shpell-gitlog-position 'right'
set -g @shpell-gitlog-width '50%'

# Rust build with smart replay
bind-key -T prefix b run-shell "custom_shpell standard build 'cargo build' --replay"
```

Reload config: `tmux source-file ~/.tmux.conf`

---
## License

MIT
