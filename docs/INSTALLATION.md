# Installation

## Automated Installation (Recommended)

Run the interactive installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/navahas/tmux-grimoire/main/install.sh)
```

The installer will:
- Detect your tmux setup (TPM or manual)
- Clone/update the grimoire repository
- Add appropriate configuration to `~/.tmux.conf`
- Include example custom shpells as comments
- Provide clear next steps

## Manual Installation

### With TPM (Tmux Plugin Manager)

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

### Without TPM

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

## Verifying Installation

After installation, you should be able to use:
- `prefix + f` to open the main shpell
- `prefix + H` to see the grimoire welcome screen

If the keybindings don't work, ensure you've reloaded your tmux configuration or restart your tmux session.
