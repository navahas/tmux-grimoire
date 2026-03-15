# Installation

## Automated Setup (Recommended)

Summon the installer with a single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/navahas/tmux-grimoire/main/install.sh)
```

The script will:
- Detect your tmux setup (TPM or manual)
- Clone/update the grimoire repository
- Add appropriate configuration to `~/.tmux.conf`
- Include example custom shpells as comments
- Provide clear next steps

---
## Manual Installation

<details>
<summary>With Plugin Manager</summary>

### TPM (Tmux Plugin Manager)

The most known, although unmaintained https://github.com/tmux-plugins/tpm

1. Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'navahas/tmux-grimoire'
```

2. Install the plugin:
   - Press `prefix + I` inside tmux

3. Reload tmux configuration:

```bash
tmux source-file ~/.tmux.conf
```

### Plux (TPM in Rust)

For rust lovers. https://github.com/nfejzic/plux

1. Add to your `~/.config/tmux/plux.toml`:

```toml
[plugins]
tmux-grimoire = "https://github.com/navahas/tmux-grimoire"
```

2. Reload tmux configuration and it will update all plugins:

```bash
tmux source-file ~/.tmux.conf
```

</details>

<details>
<summary>Without Plugin Manager</summary>

1. Clone the repository:

```bash
git clone https://github.com/navahas/tmux-grimoire.git ~/.tmux/plugins/tmux-grimoire
```

2. Add to your `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/tmux-grimoire/grimoire.tmux
```

3. Reload tmux configuration:

```bash
tmux source-file ~/.tmux.conf
```

</details>

---
## Verifying Installation

After installation, you should be able to use:
- `prefix + f` to open the main shpell
- `prefix + H` to see the grimoire welcome screen

If the keybindings don't work, ensure you've reloaded your tmux configuration or restart your tmux session.
