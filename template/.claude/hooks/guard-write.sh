#!/bin/bash
# PreToolUse on Edit|Write. Blocks edits to generated or secret files.
# Project paths come from config.sh next to this script.
input=$(cat)
path=$(printf '%s' "$input" | /usr/bin/python3 -I -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
[ -z "$path" ] && exit 0
here="$(cd "$(dirname "$0")" && pwd)"
[ -f "$here/config.sh" ] && . "$here/config.sh"

for pat in $GENERATED_PATHS; do
  case "$path" in
    $pat) echo "Blocked: $path is generated. ${GENERATED_HINT:-Edit the source instead.}" >&2; exit 2 ;;
  esac
done
case "$path" in
  */.env|*/.env.*) [[ "$path" == *.env.example ]] || { echo "Blocked: $path holds secrets. Only .env.example is edited in the repo." >&2; exit 2; } ;;
  */CONSTRAINTS.md) echo "Warning: CONSTRAINTS.md may only be changed when the user asks for it in this session. Confirm before proceeding." >&2; exit 2 ;;
esac
if [ -n "$UPSTREAM_SKILLS_DIR" ]; then
  case "$path" in
    */$UPSTREAM_SKILLS_DIR/*) echo "Blocked: $UPSTREAM_SKILLS_DIR/ is the upstream copy. Edit .claude/skills/ instead." >&2; exit 2 ;;
  esac
fi
exit 0
