#!/bin/sh
# Background poller for tmux-opencode-usage.
# Queries opencode's SQLite DB and writes a formatted string to a cache file.
#
# Usage: poll.sh <cache_file> <lock_file>
#
# Adaptive interval: resets to MIN_INTERVAL on any change, doubles each idle
# cycle up to MAX_INTERVAL. Uses only sh, sqlite3, and awk — no python3.

CACHE_FILE="${1:-${TMPDIR:-/tmp}/opencode_usage_cache}"
LOCK_FILE="${2:-${TMPDIR:-/tmp}/opencode_usage_poll.lock}"
DB="$HOME/.local/share/opencode/opencode.db"
MIN_INTERVAL=2
MAX_INTERVAL=60

# Single-instance guard
if [ -f "$LOCK_FILE" ]; then
    old_pid=$(cat "$LOCK_FILE")
    if kill -0 "$old_pid" 2>/dev/null; then
        exit 0
    fi
fi
printf "%s" "$$" > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT INT TERM

fmt_tok() {
    awk -v t="$1" 'BEGIN {
        if      (t >= 1000000) printf "%.1fM", t/1000000
        else if (t >= 1000)    printf "%dk",   int(t/1000)
        else                   printf "%d",    t
    }'
}

query() {
    # 24 hours ago in milliseconds — pure shell arithmetic, no python3
    since_ms=$(( ($(date +%s) - 86400) * 1000 ))

    result=$(sqlite3 "$DB" "
SELECT
  (SELECT COUNT(*)
   FROM message m
   JOIN session s ON m.session_id = s.id
   WHERE json_extract(m.data, '$.role') = 'user'
     AND s.parent_id IS NULL
     AND CAST(json_extract(m.data, '$.time.created') AS INTEGER) >= ${since_ms}),
  COALESCE(SUM(CAST(json_extract(m.data, '$.tokens.input')  AS INTEGER)), 0),
  COALESCE(SUM(CAST(json_extract(m.data, '$.tokens.output') AS INTEGER)), 0)
FROM message m
JOIN session s ON m.session_id = s.id
WHERE json_extract(m.data, '$.role')       = 'assistant'
  AND json_extract(m.data, '$.providerID') = 'anthropic'
  AND CAST(json_extract(m.data, '$.time.created') AS INTEGER) >= ${since_ms}
" 2>/dev/null)

    [ -z "$result" ] && return 1

    msgs=$(printf "%s" "$result"     | cut -d'|' -f1)
    input_tok=$(printf "%s" "$result" | cut -d'|' -f2)
    output_tok=$(printf "%s" "$result" | cut -d'|' -f3)
    total_tok=$(( input_tok + output_tok ))
    tok_str=$(fmt_tok "$total_tok")

    printf "%s" "${msgs}msg ${tok_str}tok"
}

interval=$MIN_INTERVAL
last=""

while true; do
    if [ ! -f "$DB" ] || ! command -v sqlite3 >/dev/null 2>&1; then
        printf "no opencode db" > "$CACHE_FILE"
        sleep $MAX_INTERVAL
        continue
    fi

    current=$(query)

    if [ -n "$current" ]; then
        printf "%s" "$current" > "$CACHE_FILE"
        if [ "$current" != "$last" ]; then
            interval=$MIN_INTERVAL
            last="$current"
        else
            interval=$(( interval * 2 ))
            [ "$interval" -gt "$MAX_INTERVAL" ] && interval=$MAX_INTERVAL
        fi
    fi

    sleep "$interval"
done
