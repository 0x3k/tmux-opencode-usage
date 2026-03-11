#!/bin/sh
# Display script for tmux-opencode-usage.
# Reads the cache file written by poll.sh and prints its contents.
# Called by tmux via #(display.sh) on every status-interval tick.
#
# Usage: display.sh <cache_file>

CACHE_FILE="${1:-${TMPDIR:-/tmp}/opencode_usage_cache}"

if [ -f "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
else
    printf "opencode n/a"
fi
