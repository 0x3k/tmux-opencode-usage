#!/usr/bin/env bash
# tmux-opencode-usage - tmux status bar plugin for opencode AI usage
# Shows prompts sent and tokens consumed in the last 24 hours.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLL_SCRIPT="$PLUGIN_DIR/scripts/poll.sh"
DISPLAY_SCRIPT="$PLUGIN_DIR/scripts/display.sh"

# User-configurable options with defaults
LOCK_FILE="${TMPDIR:-/tmp}/opencode_usage_poll.lock"
CACHE_FILE="${TMPDIR:-/tmp}/opencode_usage_cache"

tmux set-option -gq @opencode_usage_lock_file  "$LOCK_FILE"
tmux set-option -gq @opencode_usage_cache_file "$CACHE_FILE"

# Start the background poller (single-instance guard is inside the script)
tmux run-shell "\"$POLL_SCRIPT\" \"$CACHE_FILE\" \"$LOCK_FILE\" &"

# Register the interpolation variable that users can drop into any format string:
#   set -ag status-right "#{@opencode_usage}"
tmux set-option -g @opencode_usage "#($DISPLAY_SCRIPT $CACHE_FILE)"
