# tmux-opencode-usage

A tmux plugin that shows your [opencode](https://opencode.ai) AI usage in the status bar — prompts sent and tokens consumed in the last 24 hours.

```
 65msg 508ktok
```

Counts update adaptively: every 2 seconds while you are actively using opencode, backing off to 60 seconds when idle.

## How it works

opencode stores all session data in a local SQLite database at `~/.local/share/opencode/opencode.db`. This plugin queries that database directly — no API keys, no network requests.

- **Prompts**: user messages in top-level sessions (sub-agent turns are excluded)
- **Tokens**: all input + output tokens from Anthropic models in the last 24 hours
- **Adaptive polling**: a background process samples the DB every 2s on activity, doubling the interval up to 60s when idle, using only `sh`, `sqlite3`, and `awk`

## Requirements

- tmux >= 3.0
- [opencode](https://opencode.ai) with at least one session using an Anthropic model
- `sqlite3` (pre-installed on macOS; `apt install sqlite3` on Linux)

## Installation

### With TPM

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'your-username/tmux-opencode-usage'
```

Then press `prefix + I` to install.

### Manual

```sh
git clone https://github.com/your-username/tmux-opencode-usage ~/.tmux/plugins/tmux-opencode-usage
```

Add to `~/.tmux.conf`:

```tmux
run '~/.tmux/plugins/tmux-opencode-usage/opencode-usage.tmux'
```

## Usage

After installation the plugin exposes `#{E:@opencode_usage}` which you can place anywhere in your status line. The `E:` flag is required to tell tmux to evaluate the shell command inside the variable.

```tmux
set -ag status-right " #{E:@opencode_usage}"
```

### With catppuccin

If you use the [catppuccin tmux theme](https://github.com/catppuccin/tmux), you can integrate it as a styled module. Add a file `~/.tmux/custom/opencode.conf`:

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

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `@opencode_usage_window` | `today` | Time window for usage counts: `today` or `24h` |
| `@opencode_usage_db` | `~/.local/share/opencode/opencode.db` | Path to opencode database |

### `@opencode_usage_window`

Controls the time window over which prompts and tokens are counted:

- **`today`** (default) — counts from 00:00 of the current calendar day. Resets at midnight.
- **`24h`** — rolling 24-hour window. Always shows the last 24 hours regardless of time of day.

```tmux
# Use rolling 24-hour window instead of calendar day
set -g @opencode_usage_window "24h"
```

## License

MIT
