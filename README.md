![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![tmux 3.2+](https://img.shields.io/badge/tmux-3.2+-brightgreen)

# Tmux Grimoire

Summonable popup shells (`shpells`) for tmux — customizable, scriptable, and driven by keybindings.

![Preview](https://raw.githubusercontent.com/navahas/tmux-grimoire/assets/images/grimoire.png)

## Installation

Run the interactive installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/navahas/tmux-grimoire/main/install.sh)
```

The installer will detect your setup, configure keybindings, and add example shpells to `~/.tmux.conf`.

**Prefer manual setup?** See [docs/INSTALLATION.md](docs/INSTALLATION.md)

## Quick Reference

Default keybindings:

| Keybind | Action |
|---------|--------|
| `prefix + f` | Toggle main shpell |
| `prefix + F` | Open ephemeral shpell |
| `prefix + H` | Show grimoire welcome screen |
| `prefix + C` | Close current shpell |

## What's Next?

After installation, your `~/.tmux.conf` will include example custom shpells (commented out). Uncomment and customize them to create your own magical shortcuts.

**Documentation:**
- **[Custom Shpells](docs/CUSTOM_SHPELLS.md)** — Create custom keybindings, understand `--replay` logic
- **[Configuration](docs/CONFIGURATION.md)** — Customize appearance, position, and behavior
- **[Advanced Usage](docs/ADVANCED.md)** — Window management, splits, and integrations

**External Resources:**
- **[grimoire](https://github.com/navahas/grimoire)** — Collection of ready-to-use shpell scripts

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

## License

MIT
