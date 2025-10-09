#!/usr/bin/env bash
set -euo pipefail

# --- Styling ---------------------------------------------------------
bold=$(tput bold 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
cyan=$(tput setaf 6 2>/dev/null || true)
red=$(tput setaf 1 2>/dev/null || true)
purple=$(tput setaf 5 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)
dim=$(tput dim 2>/dev/null || true)

info() { printf "%s>%s %s\n" "$cyan" "$reset" "$*"; }
ok()   { printf "%s[+]%s %s\n" "$green" "$reset" "$*"; }
err()  { printf "%s[!]%s %s\n" "$red" "$reset" "$*" >&2; }
step() { printf "%s>>%s %s" "$purple" "$reset" "$*"; }

# Typing effect
type_text() {
    local text="$1"
    local delay="${2:-0.05}"
    local i=0
    while [ $i -lt ${#text} ]; do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
        i=$((i + 1))
    done
}

# --- Act 1: The Summoning --------------------------------------------
clear
printf "%s" "$purple"

# Fade-in effect for ASCII art
while IFS= read -r line; do
    printf "%s\n" "$line"
    sleep 0.033
done <<'GRIMOIRE'
╭─────────────────────────────────────────────────────────────────╮
│                                                                 │
│            ████████╗███╗   ███╗██╗   ██╗██╗   ██╗               │
│            ╚══██╔══╝████╗ ████║██║   ██║ ██╗ ██╔╝               │
│               ██║   ██╔████╔██║██║   ██║  ████╔╝                │
│               ██║   ██║╚██╔╝██║██║   ██║ ██╔═██╗                │
│               ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝  ██╗               │
│               ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝   ╚═╝               │
│                                                                 │
│    ██████╗ ██████╗ ██╗███╗   ███╗ ██████╗ ██╗██████╗ ███████╗   │
│   ██╔════╝ ██╔══██╗██║████╗ ████║██╔═══██╗██║██╔══██╗██╔════╝   │
│   ██║  ███╗██████╔╝██║██╔████╔██║██║   ██║██║██████╔╝█████╗     │
│   ██║   ██║██╔══██╗██║██║╚██╔╝██║██║   ██║██║██╔══██╗██╔══╝     │
│   ╚██████╔╝██║  ██║██║██║ ╚═╝ ██║╚██████╔╝██║██║  ██║███████╗   │
│    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝   │
│                                                                 │
╰─────────────────────────────────────────────────────────────────╯

                .-~~~~~~~~~-._       _.-~~~~~~~~~-.
            __.'              ~.   .~              `.__
          .'//                  \./                  \\`.
        .'//                     |                     \\`.
      .'// .-~"""""""~~~~-._     |     _,-~~~~"""""""~-. \\`.
    .'//.-"                 `-.  |  .-'                 "-.\\`.
  .'//______.============-..   \ | /   ..-============.______\\`.
.'______________________________\|/______________________________`.

GRIMOIRE

printf "%s" "$reset"
sleep 2.3

clear

# Recognition sequence
whoami=$(whoami)

printf "%s%s" "$purple"
printf "\n\n"
sleep 0.8
type_text "....The Grimoire recognizes you, $yellow$whoami$purple...." 0.033
printf "%s\n" "$reset"
sleep 1.3

printf "%s" "$purple"
type_text "....You are about to bind its powers to your terminal...." 0.033
printf "%s\n\n" "$reset"
sleep 1.1

# --- Detect environment ----------------------------------------------
has() { command -v "$1" >/dev/null 2>&1; }
PREFIX="${PREFIX:-$HOME/.tmux/plugins/tmux-grimoire}"
CONF="${TMUX_CONF:-$HOME/.tmux.conf}"

step "Checking dependencies..."
sleep 0.5
has tmux || { printf "\n"; err "tmux not found. Please install tmux first."; exit 1; }
has curl || { printf "\n"; err "curl not found. Please install curl."; exit 1; }
printf " %s[+]%s\n" "$green" "$reset"
sleep 0.3

# --- Act 2: Detection ------------------------------------------------
# Helpers for tmux.conf
backup_once() {
    [ -f "$CONF" ] || : > "$CONF"
    [ -f "${CONF}.bak" ] || cp "$CONF" "${CONF}.bak"
}
conf_has_line() { grep -Fqx "$1" "$CONF" 2>/dev/null; }

# Detect TPM by dir or bootstrap line
TPM_REGEX='^[[:space:]]*run(-shell)?[[:space:]]+['"'"'"]?~\/\.tmux\/plugins\/tpm\/tpm['"'"'"]?[[:space:]]*$'
has_tpm_dir() { [ -d "$HOME/.tmux/plugins/tpm" ]; }
conf_has_tpm_bootstrap() { grep -qiE "$TPM_REGEX" "$CONF" 2>/dev/null; }

step "Detecting tmux setup...."
sleep 0.8
printf " %s[+]%s\n" "$green" "$reset"

USE_TPM=0
if has_tpm_dir || conf_has_tpm_bootstrap; then
    printf "  %s->%s Found TPM installation\n" "$cyan" "$reset"
    printf "  %s->%s Will configure via TPM plugin manager\n" "$dim" "$reset"
    USE_TPM=1
else
    printf "  %s->%s TPM not detected\n" "$cyan" "$reset"
    printf "  %s->%s Will configure with manual method\n" "$dim" "$reset"
fi
sleep 0.8

# --- Act 3: The Question ---------------------------------------------
printf "\n%s%sReady to proceed?%s [Y/n] " "$bold" "$purple" "$reset"
read -r answer
case "${answer}" in
    [Nn]*)
        printf "\n%s" "$dim"
        type_text "Perhaps another time... The grimoire awaits." 0.01
        printf "%s\n\n" "$reset"
        exit 0
        ;;
    *)
        # Default: proceed with installation
        ;;
esac

printf "\n"

# --- Act 4: The Installation -----------------------------------------
step "Summoning grimoire from the repository"
printf "\n"
sleep 0.5

if has git; then
    if [ -d "$PREFIX/.git" ]; then
        printf "  %s...%s updating existing grimoire\n" "$dim" "$reset"
        git -C "$PREFIX" pull --ff-only >/dev/null 2>&1
        sleep 0.5
    else
        printf "  %s...%s cloning from github\n" "$dim" "$reset"
        git clone --depth 1 https://github.com/navahas/tmux-grimoire "$PREFIX" >/dev/null 2>&1
        sleep 1
    fi
else
    printf "  %s...%s downloading archive\n" "$dim" "$reset"
    tmp="$(mktemp -d)"
    curl -fsSL https://codeload.github.com/navahas/tmux-grimoire/tar.gz/refs/heads/main \
        | tar -xz -C "$tmp"
            rm -rf "$PREFIX"
            mv "$tmp"/tmux-grimoire-* "$PREFIX"
            rm -rf "$tmp"
            sleep 1
fi

ok "Grimoire installed to $PREFIX"
sleep 0.5

# --- Act 5: Configuration --------------------------------------------
step "Configuring keybindings and settings"
printf "\n"
sleep 0.5

# Notify about backup
if [ -f "$CONF" ] && [ ! -f "${CONF}.bak" ]; then
    printf "  %s->%s Preserving original configuration at %s%s.bak%s\n" "$cyan" "$reset" "$dim" "$CONF" "$reset"
    sleep 0.4
fi

GRIMOIRE_TPM_LINE="set -g @plugin 'navahas/tmux-grimoire'"
GRIMOIRE_MANUAL_LINE="run-shell ~/.tmux/plugins/tmux-grimoire/grimoire.tmux"

ensure_with_tpm() {
    backup_once
    conf_has_line "$GRIMOIRE_TPM_LINE" && return 0

    # Insert plugin line + config template BEFORE the TPM bootstrap line (first match).
    awk -v plugin="$GRIMOIRE_TPM_LINE" '
    BEGIN { inserted=0 }
    {
        line=$0
        if (!inserted && match(tolower(line), /^[[:space:]]*run(-shell)?[[:space:]]+['"'"'"]?~\/\.tmux\/plugins\/tpm\/tpm['"'"'"]?[[:space:]]*$/)) {
            print plugin
            print ""
            print "# ─── Tmux Grimoire Configuration ───────────────"
            print "# Uncomment and customize these options as needed"
            print ""
            print "# Global appearance"
            print "# set -g @grimoire-title '\'' grimoire '\''"
            print "# set -g @grimoire-color '\''#c6b7ee'\''"
            print "# set -g @grimoire-width '\''80%'\''"
            print "# set -g @grimoire-height '\''30%'\''"
            print "# set -g @grimoire-position '\''bottom-center'\''"
            print ""
            print "# Example custom shpells:"
            print "# Standard shpell (persistent)"
            print "# bind-key -T prefix q run-shell \"custom_shpell standard dev\""
            print ""
            print "# Ephemeral shpell with custom styling (closes after use)"
            print "# bind-key -T prefix G run-shell \"custom_shpell ephemeral gitlog \\\"git log --oneline --graph --decorate --all\\\"\""
            print "# set -g @shpell-gitlog-color    '\''#e3716e'\''"
            print "# set -g @shpell-gitlog-position '\''right'\''"
            print "# set -g @shpell-gitlog-width    '\''50%'\''"
            print "# set -g @shpell-gitlog-height   '\''100%'\''"
            print ""
            print "# More examples:"
            print "# bind-key -T prefix E run-shell \"custom_shpell standard notes\""
            print "# bind-key -T prefix b run-shell \"custom_shpell standard rust-build '\''cargo build'\'' --replay\""
            print ""
            inserted=1
        }
        print line
    }
    END {
        if (!inserted) {
            print ""
            print plugin
            print ""
            print "# ─── Tmux Grimoire Configuration ───────────────"
            print "# Uncomment and customize these options as needed"
            print ""
            print "# Global appearance"
            print "# set -g @grimoire-title '\'' grimoire '\''"
            print "# set -g @grimoire-title '\'' 󱥭 '\'' # Nerd Font Icon (optional)"
            print "# set -g @grimoire-color '\''#c6b7ee'\''"
            print "# set -g @grimoire-width '\''80%'\''"
            print "# set -g @grimoire-height '\''30%'\''"
            print "# set -g @grimoire-position '\''bottom-center'\''"
            print ""
            print "# Example custom shpells:"
            print "# Standard shpell (persistent)"
            print "# bind-key -T prefix q run-shell \"custom_shpell standard dev\""
            print ""
            print "# Ephemeral shpell with custom styling (closes after use)"
            print "# bind-key -T prefix G run-shell \"custom_shpell ephemeral gitlog \\\"git log --oneline --graph --decorate --all\\\"\""
            print "# set -g @shpell-gitlog-color    '\''#e3716e'\''"
            print "# set -g @shpell-gitlog-position '\''right'\''"
            print "# set -g @shpell-gitlog-width    '\''50%'\''"
            print "# set -g @shpell-gitlog-height   '\''100%'\''"
            print ""
            print "# More examples:"
            print "# bind-key -T prefix E run-shell \"custom_shpell standard notes\""
            print "# bind-key -T prefix b run-shell \"custom_shpell standard rust-build '\''cargo build'\'' --replay\""
        }
    }
    ' "$CONF" > "$CONF.tmp" && mv "$CONF.tmp" "$CONF"
}

ensure_manual() {
    backup_once
    conf_has_line "$GRIMOIRE_MANUAL_LINE" && return 0
    {
        printf "\n# ─── Tmux Grimoire Configuration ───────────────\n"
        printf "# Uncomment and customize these options as needed\n\n"
        printf "# Global appearance\n"
        printf "# set -g @grimoire-title ' grimoire '\n"
        printf "# set -g @grimoire-color '#c6b7ee'\n"
        printf "# set -g @grimoire-width '80%%'\n"
        printf "# set -g @grimoire-height '30%%'\n"
        printf "# set -g @grimoire-position 'bottom-center'\n\n"
        printf "# Example custom shpells:\n"
        printf "# Standard shpell (persistent)\n"
        printf "# bind-key -T prefix q run-shell \"custom_shpell standard dev\"\n\n"
        printf "# Ephemeral shpell with custom styling (closes after use)\n"
        printf "# bind-key -T prefix G run-shell \"custom_shpell ephemeral gitlog \\\"git log --oneline --graph --decorate --all\\\"\"\n"
        printf "# set -g @shpell-gitlog-color '#e3716e'\n"
        printf "# set -g @shpell-gitlog-position 'right'\n"
        printf "# set -g @shpell-gitlog-width '50%%'\n"
        printf "# set -g @shpell-gitlog-height '100%%'\n\n"
        printf "# More examples:\n"
        printf "# bind-key -T prefix E run-shell \"custom_shpell standard notes\"\n"
        printf "# bind-key -T prefix b run-shell \"custom_shpell standard rust-build 'cargo build' --replay\"\n\n"
        printf "# tmux-grimoire (manual install)\n"
        printf "%s\n" "$GRIMOIRE_MANUAL_LINE"
    } >>"$CONF"
}

# Update tmux.conf based on TPM detection
if [ "$USE_TPM" -eq 1 ]; then
    printf "  %s...%s adding TPM plugin line and configuration\n" "$dim" "$reset"
    ensure_with_tpm
    sleep 0.5
else
    printf "  %s...%s adding manual run-shell line and configuration\n" "$dim" "$reset"
    ensure_manual
    sleep 0.5
fi

ok "Configuration added to $CONF"
sleep 0.5

# --- Act 6: The Completion -------------------------------------------
printf "%s" "$purple"
while IFS= read -r line; do
    printf "%s\n" "$line"
    sleep 0.033
done <<'SUCCESS'

╭──────────────────────────────────────────────╮
│                                              │
│ The Grimoire has been summoned successfully! │
│                                              │
╰──────────────────────────────────────────────╯

SUCCESS
printf "%s" "$reset"
sleep 3.3
clear

printf "\n\n"
printf "%s%sNext Steps:%s\n\n" "$bold" "$purple" "$reset"

if [ "$USE_TPM" -eq 1 ]; then
    printf "%s1.%s Install the plugin with TPM (inside tmux):\n" "$purple" "$reset"
    printf "   %sPress %sprefix + I%s%s in tmux%s\n\n" "$dim" "$reset$yellow"  "$reset$dim"
    printf "%s2.%s Reload tmux configuration:\n" "$purple" "$reset"
    printf "   %stmux source-file \"%s\"%s\n\n" "$yellow" "$CONF" "$reset"
else
    printf "%s1.%s Reload tmux configuration:\n" "$cyan" "$reset"
    printf "   %stmux source-file \"%s\"%s\n\n" "$yellow" "$CONF" "$reset"
    printf "%s2.%s Or restart tmux to activate the plugin\n\n" "$cyan" "$reset"
fi

sleep 2.4
printf "%s%sTry These Commands:%s\n\n" "$bold" "$purple" "$reset"
printf "   %sprefix + f%s%s....%s Open/Close your main shpell\n" "$green" "$reset" "$dim" "$reset"
printf "   %s.............. Also used to close any shpell%s\n" "$dim" "$reset"
printf "   %sprefix + F%s%s....%s Open an ephemeral shpell\n" "$green" "$reset" "$dim" "$reset"
printf "   %sprefix + H%s%s....%s Display the grimoire welcome screen\n" "$green" "$reset" "$dim" "$reset"
printf "   %sprefix + C%s%s....%s Close the current shpell\n\n" "$green" "$reset" "$dim" "$reset"

sleep 2.4
printf "%s%sCustomize:%s\n\n" "$bold" "$purple" "$reset"
printf "Edit %s%s%s and uncomment the example shpells\n" "$cyan" "$CONF" "$reset"
printf "at the bottom to create your own magical shortcuts!\n\n"
printf "%sFor more info: %shttps://github.com/navahas/tmux-grimoire%s\n\n" "$dim" "$cyan" "$reset"
