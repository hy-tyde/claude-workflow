#!/bin/bash
# Stop hook. Before Claude ends a turn with uncommitted code changes, the fast checks must pass.
# CODE_DIRS and CHECK_CMD come from config.sh next to this script.
input=$(cat)
active=$(printf '%s' "$input" | /usr/bin/python3 -I -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active",False))' 2>/dev/null)
[ "$active" = "True" ] && exit 0            # never loop
root="${CLAUDE_PROJECT_DIR:-.}"
here="$(cd "$(dirname "$0")" && pwd)"
[ -f "$here/config.sh" ] && . "$here/config.sh"
[ -n "$CHECK_CMD" ] && [ -n "$CODE_DIRS" ] || exit 0
# Default CHECK_CMD is a make target: skip quietly until the Makefile has it.
case "$CHECK_CMD" in make*) { [ -f "$root/Makefile" ] && grep -qE "^${CHECK_CMD#make }:" "$root/Makefile"; } || exit 0 ;; esac
changed=$(git -C "$root" status --porcelain -- $CODE_DIRS 2>/dev/null | wc -l | tr -d ' ')
[ "$changed" = "0" ] && exit 0
out=$(cd "$root" && timeout 90 $CHECK_CMD 2>&1) && exit 0
echo "$CHECK_CMD failed with uncommitted changes in $CODE_DIRS. Fix or explain before ending the turn:
$(printf '%s' "$out" | tail -40)" >&2
exit 2
