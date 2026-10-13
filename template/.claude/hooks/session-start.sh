#!/bin/bash
# SessionStart. Tells a fresh session which spec is active and what is open. stdout becomes context.
root="${CLAUDE_PROJECT_DIR:-.}"
branch=$(git -C "$root" branch --show-current 2>/dev/null)
case "$branch" in
  features/*) slug="${branch#features/}"; dir="$root/docs/specs/$slug" ;;
  bugs/*)     echo "Branch $branch. Follow docs/swe/fix_bug.md: failing test first."; exit 0 ;;
  *)          echo "Branch $branch. No active spec. Feature work starts with a features/NN-slug worktree (docs/swe/build_feature.md)."; exit 0 ;;
esac
if [ ! -f "$dir/spec.md" ]; then echo "Branch $branch but no $dir/spec.md yet. Run /feature <brief>."; exit 0; fi
status=$(grep -m1 -E '^Status:' "$dir/spec.md")
echo "Active spec: docs/specs/$slug/spec.md ($status)"
if [ -f "$dir/tasks.md" ]; then
  open=$(grep -cE '^- \[ \]' "$dir/tasks.md"); done=$(grep -cE '^- \[x\]' "$dir/tasks.md")
  echo "Tasks: $done done, $open open. Next open tasks:"
  grep -E '^- \[ \]' "$dir/tasks.md" | head -3
  echo "Continue with /feature continue."
else
  echo "No plan yet. After approval run /feature continue."
fi
