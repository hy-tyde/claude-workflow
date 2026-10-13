#!/bin/bash
# Copies the Claude Code workflow (template/) into a target project.
#
#   ./install.sh <target-dir> [--force] [--only claude|docs|github|all]
#
# Default: copy everything, never overwrite a file that already exists in the target.
# --force      overwrite existing files (your project-specific edits are replaced; diff first)
# --only       limit to one group: claude (.claude/), docs (CLAUDE.md, docs/, dev-notes/, .gitignore), github (.github/)
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
src="$here/template"
target="${1:-}"; shift || true
force=0; only=all
while [ $# -gt 0 ]; do
  case "$1" in
    --force) force=1 ;;
    --only) only="$2"; shift ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done
[ -n "$target" ] && [ -d "$target" ] || { echo "usage: $0 <existing-target-dir> [--force] [--only claude|docs|github|all]" >&2; exit 1; }
target="$(cd "$target" && pwd)"

copied=0; skipped=0
copy_tree() {  # copy_tree <relative path under template>
  local rel="$1"
  [ -e "$src/$rel" ] || return 0
  find "$src/$rel" -type f ! -name .DS_Store | while read -r f; do
    local dest="$target/${f#$src/}"
    if [ -e "$dest" ] && [ "$force" = 0 ]; then
      echo "skip   ${f#$src/} (exists)"
    else
      mkdir -p "$(dirname "$dest")"
      cp "$f" "$dest"
      echo "copy   ${f#$src/}"
    fi
  done
}

case "$only" in
  all|claude) copy_tree .claude ;;
esac
case "$only" in
  all|docs) copy_tree CLAUDE.md; copy_tree .gitignore; copy_tree docs; copy_tree dev-notes ;;
esac
case "$only" in
  all|github) copy_tree .github ;;
esac

chmod +x "$target"/.claude/hooks/*.sh 2>/dev/null || true

cat <<EOF

Installed into $target. Next:
  1. Edit $target/.claude/hooks/config.sh (code dirs, generated paths, check command).
  2. Fill the placeholders in CLAUDE.md and dev-notes/plan/01-execution-plan.md.
  3. Add a 'check' target to the Makefile so the stop gate runs.
  4. Commit on main with: ALLOW_MAIN_COMMIT=1 git commit -m "chore: add Claude workflow"
EOF
