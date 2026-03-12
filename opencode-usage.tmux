#!/usr/bin/env bash
# tmux-opencode-usage - tmux status bar plugin for opencode AI usage
# Shows prompts sent and tokens consumed for the configured time window.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLL_SCRIPT="$PLUGIN_DIR/scripts/poll.sh"
DISPLAY_SCRIPT="$PLUGIN_DIR/scripts/display.sh"

CACHE_FILE="${TMPDIR:-/tmp}/opencode_usage_cache"
LOCK_FILE="${TMPDIR:-/tmp}/opencode_usage_poll.lock"

# Read user options
WINDOW=$(tmux show-option -gv @opencode_usage_window 2>/dev/null)
WINDOW="${WINDOW:-today}"

tmux set-option -gq @opencode_usage_cache_file "$CACHE_FILE"
tmux set-option -gq @opencode_usage_lock_file  "$LOCK_FILE"

# Start the background poller using -b so tmux doesn't block waiting for it.
# Format is read by poll.sh directly from @opencode_usage_format to avoid
# tmux run-shell mangling special characters in the format string.
tmux run-shell -b "\"$POLL_SCRIPT\" \"$CACHE_FILE\" \"$LOCK_FILE\" \"$WINDOW\""

# Expose #{E:@opencode_usage} for use in any status format string.
# The E: flag is required so tmux evaluates the #() inside the variable value.
tmux set-option -g @opencode_usage "#($DISPLAY_SCRIPT \"$CACHE_FILE\")"
