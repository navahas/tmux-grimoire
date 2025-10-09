<p align="center">
    <img src="https://raw.githubusercontent.com/navahas/tmux-grimoire/assets/images/grimoire.png"
        alt="preview_tmux_grimoire" width="500"/>
</p>

![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)
![tmux 3.2+](https://img.shields.io/badge/tmux-3.2+-brightgreen)

# Tmux Grimoire

Summonable popup shells (`shpells`) for tmux: customizable, scriptable and driven by keybindings.

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
| `prefix + f` | Open the main shpell, or close any active one |
| `prefix + F` | Summon a new ephemeral shpell |
| `prefix + C` | Close and dismiss the current shpell |
| `prefix + H` | Reveal the Grimoire welcome banner |

## Awaken the Grimoire

After installation, your `~/.tmux.conf` will include example shpells (commented out). Uncomment and customize them to shape your workflow.

**Documentation:**
- [Configuration](docs/CONFIGURATION.md)  | Adjust colors, size and position
- [Custom Shpells](docs/CUSTOM_SHPELLS.md) | Create custom keybindings and use the `--replay` mode
- [Advanced Usage](docs/ADVANCED.md) | Manage windows, splits and integrations

---
## License

MIT
