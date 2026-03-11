#!/usr/bin/env bash
# tmux-opencode-usage - tmux status bar plugin for opencode AI usage
# Shows prompts sent and tokens consumed for the configured time window.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLL_SCRIPT="$PLUGIN_DIR/scripts/poll.sh"
DISPLAY_SCRIPT="$PLUGIN_DIR/scripts/display.sh"

CACHE_FILE="${TMPDIR:-/tmp}/opencode_usage_cache"
LOCK_FILE="${TMPDIR:-/tmp}/opencode_usage_poll.lock"

# Read user option: "today" (default) or "24h"
WINDOW=$(tmux show-option -gv @opencode_usage_window 2>/dev/null)
WINDOW="${WINDOW:-today}"

tmux set-option -gq @opencode_usage_cache_file "$CACHE_FILE"
tmux set-option -gq @opencode_usage_lock_file  "$LOCK_FILE"

# Start the background poller using -b so tmux doesn't block waiting for it
tmux run-shell -b "\"$POLL_SCRIPT\" \"$CACHE_FILE\" \"$LOCK_FILE\" \"$WINDOW\""

# Expose #{@opencode_usage} for use in any status format string
tmux set-option -g @opencode_usage "#($DISPLAY_SCRIPT $CACHE_FILE)"
