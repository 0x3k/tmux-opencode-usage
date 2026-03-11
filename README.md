<div align="center">

# tmux-opencode-usage

**Live [opencode](https://opencode.ai) AI usage in your tmux status bar.**

Prompts sent and tokens consumed — updated in real time, straight from your local database.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![tmux](https://img.shields.io/badge/tmux-%E2%89%A53.0-green?style=for-the-badge)](https://github.com/tmux/tmux)
[![opencode](https://img.shields.io/badge/opencode-compatible-orange?style=for-the-badge)](https://opencode.ai)

</div>

---

<img src="tile.png" alt="tmux-opencode-usage preview" width="400"/>

> Queries opencode's local SQLite database directly.
> No API keys. No network requests. No extra dependencies beyond `sqlite3` and `awk`.

---

## How it works

opencode stores all session data in a local SQLite database at `~/.local/share/opencode/opencode.db`. This plugin runs a lightweight background process that queries it on an **adaptive schedule**:

- **2 seconds** while you are actively using opencode
- Doubles up to **60 seconds** when idle

| Metric | What it counts |
|--------|----------------|
| **Prompts** | Your messages in top-level sessions (sub-agent turns excluded) |
| **Tokens** | Total input + output tokens from Anthropic models |
| **Window** | Configurable: from midnight today (default) or rolling 24h |

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| tmux ≥ 3.0 | |
| [opencode](https://opencode.ai) | At least one session using an Anthropic model |
| `sqlite3` | Pre-installed on macOS · `sudo apt install sqlite3` on Linux |

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
git clone https://github.com/0x3k/tmux-opencode-usage \
  ~/.tmux/plugins/tmux-opencode-usage
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

> [!NOTE]
> The `E:` flag is required. It tells tmux to evaluate the shell command stored in the variable on each status refresh.

### With catppuccin

If you use the [catppuccin tmux theme](https://github.com/catppuccin/tmux), render it as a native styled module. Create `~/.tmux/custom/opencode.conf`:

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
| `@opencode_usage_window` | `today` | `today` — from 00:00 · `24h` — rolling 24-hour window |

```tmux
# Counts from midnight, resets at 00:00 (default)
set -g @opencode_usage_window "today"

# Always show the last 24 hours
set -g @opencode_usage_window "24h"
```

---

## License

[MIT](LICENSE)
