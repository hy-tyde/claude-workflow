#!/bin/bash
# PreToolUse on Bash. Blocks dangerous git operations. Exit 2 = block, stderr goes to Claude.
input=$(cat)
cmd=$(printf '%s' "$input" | /usr/bin/python3 -I -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
[ -z "$cmd" ] && exit 0
branch=$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current 2>/dev/null)
# The documented bypass for setup commits: ALLOW_MAIN_COMMIT=1 either in the hook's environment
# or as a prefix in the command itself ("ALLOW_MAIN_COMMIT=1 git commit ..."), since Claude's Bash tool
# cannot set the hook's environment.
if printf '%s' "$cmd" | grep -qE '(^|[;&|]\s*)(env\s+)?ALLOW_MAIN_COMMIT=1\s'; then ALLOW_MAIN_COMMIT=1; fi

if printf '%s' "$cmd" | grep -qE '(^|[;&|]\s*)git\s+push\b.*(--force|-f\b|--force-with-lease)'; then
  echo "Blocked: force push is not allowed in this repo." >&2; exit 2
fi
if printf '%s' "$cmd" | grep -qE '(^|[;&|]\s*)git\s+(commit|push)\b' && [ "$branch" = "main" ] && [ "${ALLOW_MAIN_COMMIT:-0}" != "1" ]; then
  echo "Blocked: you are on main. Feature and fix work goes on features/NN-slug or bugs/slug (docs/swe/build_feature.md). Set ALLOW_MAIN_COMMIT=1 only for setup commits the user asked for." >&2; exit 2
fi
if printf '%s' "$cmd" | grep -qE 'git\s+(reset\s+--hard|clean\s+-[a-z]*f|checkout\s+--\s+\.|restore\s+\.)'; then
  echo "Blocked: destructive working-tree command. Ask the user first." >&2; exit 2
fi
exit 0
