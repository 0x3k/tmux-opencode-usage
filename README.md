# tmux-opencode-usage

A tmux status bar plugin that shows your [opencode](https://opencode.ai) AI usage in real time — prompts sent and tokens consumed, updated live as you work.

```
 42msg 318ktok
```

Queries opencode's local SQLite database directly. No API keys. No network requests. No dependencies beyond `sqlite3` and `awk`.

---

## How it works

opencode stores all session data in a local SQLite database at `~/.local/share/opencode/opencode.db`. This plugin runs a lightweight background process that queries it on an **adaptive schedule**: every 2 seconds while you are actively using opencode, backing off to 60 seconds when idle.

- **Prompts** — counts your messages in top-level sessions (sub-agent turns are excluded)
- **Tokens** — total input + output tokens consumed by Anthropic models
- **Window** — configurable: from midnight today (default) or a rolling 24-hour window

---

## Requirements

- tmux >= 3.0
- [opencode](https://opencode.ai) with at least one Anthropic model session
- `sqlite3` — pre-installed on macOS; `sudo apt install sqlite3` on Linux

---

## Installation

### With TPM (recommended)

Add to `~/.tmux.conf`:

```tmux
set -g @plugin '0x3k/tmux-opencode-usage'
```

Press `prefix + I` to install.

### Manual

```sh
git clone https://github.com/0x3k/tmux-opencode-usage ~/.tmux/plugins/tmux-opencode-usage
```

Add to `~/.tmux.conf`:

```tmux
run '~/.tmux/plugins/tmux-opencode-usage/opencode-usage.tmux'
```

---

## Usage

The plugin exposes `#{E:@opencode_usage}` — drop it anywhere in your status line:

```tmux
set -ag status-right " #{E:@opencode_usage}"
```

> The `E:` flag is required. It tells tmux to evaluate the shell command stored inside the variable.

### With catppuccin

If you use the [catppuccin tmux theme](https://github.com/catppuccin/tmux), you can render it as a native styled module. Create `~/.tmux/custom/opencode.conf`:

```tmux
# vim:set ft=tmux:
%hidden MODULE_NAME="opencode"

set -ogq "@catppuccin_${MODULE_NAME}_icon" " "
set -ogqF "@catppuccin_${MODULE_NAME}_color" "#{E:@thm_mauve}"
set -ogq "@catppuccin_${MODULE_NAME}_text" " #{E:@opencode_usage}"

source ~/.tmux/plugins/tmux/utils/status_module.conf
```

Then in `~/.tmux.conf`, after loading catppuccin:

```tmux
source ~/.tmux/custom/opencode.conf
set -ag status-right "#{E:@catppuccin_status_opencode}"
```

---

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `@opencode_usage_window` | `today` | `today` — from 00:00; `24h` — rolling 24-hour window |

```tmux
# Default: counts from midnight, resets at 00:00
set -g @opencode_usage_window "today"

# Alternative: always show the last 24 hours
set -g @opencode_usage_window "24h"
```

---

## License

MIT
