#!/bin/bash
# PostToolUse on Edit|Write. Lints the changed file if the toolchain exists. Exit 2 feeds the errors back to Claude.
# Project dirs come from config.sh next to this script.
input=$(cat)
path=$(printf '%s' "$input" | /usr/bin/python3 -I -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
[ -z "$path" ] || [ ! -f "$path" ] && exit 0
root="${CLAUDE_PROJECT_DIR:-.}"
here="$(cd "$(dirname "$0")" && pwd)"
[ -f "$here/config.sh" ] && . "$here/config.sh"
case "$path" in
  *.py)
    [ -n "$PY_DIR" ] && [ -f "$root/$PY_DIR/pyproject.toml" ] && command -v uv >/dev/null || exit 0
    out=$(cd "$root/$PY_DIR" && uv run --quiet ruff check --quiet "$path" 2>&1) || { echo "ruff: $out" >&2; exit 2; } ;;
  *.ts|*.tsx)
    [ -n "$JS_DIR" ] && [ -d "$root/$JS_DIR/node_modules" ] || exit 0
    out=$(cd "$root/$JS_DIR" && pnpm exec eslint --no-warn-ignored "$path" 2>&1) || { echo "eslint: $out" >&2; exit 2; } ;;
esac
exit 0
