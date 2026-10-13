#!/bin/bash
# Per-project settings for the hooks. Edit this file, not the hooks.
# Every value has a safe default: unset means the matching check is a no-op.

# Space-separated glob patterns (bash case syntax) that Claude must never edit by hand.
# Example for generated types: "*/frontend/packages/schema/*"
GENERATED_PATHS=""

# The message shown when a generated path is blocked.
GENERATED_HINT="Change the source model and run the codegen target instead."

# Directories (relative to the repo root) that hold code. Uncommitted changes
# here trigger the stop gate. Example: "backend frontend" or "src".
CODE_DIRS="src"

# Where the Python project (pyproject.toml) lives, relative to the repo root.
# Leave empty if the project has no Python.
PY_DIR=""

# Where the JS/TS project (package.json, node_modules) lives, relative to the repo root.
# Leave empty if the project has no JS/TS.
JS_DIR=""

# Fast check run before a turn ends with uncommitted code. Must finish in under 90 s.
CHECK_CMD="make check"

# Directory of the upstream skills clone that must not be edited (optional).
UPSTREAM_SKILLS_DIR="agent-skills"
