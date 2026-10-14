# claude-workflow

A reusable Claude Code workflow for small product teams: spec, plan, build, review, ship, with hooks that enforce the rules the harness can check. Extracted from `hytyde-forms` and stripped of product specifics so it drops into any repo. The skills, agents and references come from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT); see [Upstream and credits](#upstream-and-credits).

## Install into a project

```
git clone <this repo> ~/HyTyde/Projects/claude-workflow
~/HyTyde/Projects/claude-workflow/install.sh /path/to/project
```

The installer copies `template/` into the target and never overwrites a file that already exists. Use `--force` to overwrite, and `--only claude|docs|github` to install one group.

Then, in the target project:

1. Edit `.claude/hooks/config.sh`: code directories, generated paths, Python and JS roots, the fast check command.
2. Fill the placeholders in `CLAUDE.md` and `dev-notes/plan/01-execution-plan.md`.
3. Add a `check` target to the Makefile (lint plus related tests, under 90 seconds). The stop gate is a no-op until it exists.
4. Commit on `main` with `ALLOW_MAIN_COMMIT=1` in front of the commit command. The bash guard blocks ordinary commits on `main`.

## What is in `template/`

| Path | What it holds |
| --- | --- |
| `.claude/commands/` | Slash commands: `/feature`, `/bug`, `/spec`, `/plan`, `/build`, `/quality-review`, `/ship`, `/constraints`, `/test` |
| `.claude/skills/` | 18 process skills selected from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills), see `skills/README.md` |
| `.claude/agents/` | Subagent personas for `/ship`: code-reviewer, security-auditor, test-engineer |
| `.claude/references/` | Checklists the skills and agents cite: definition of done, security, performance, accessibility, observability, testing, orchestration |
| `.claude/hooks/` | Guards and gates, configured by `config.sh` (see below) |
| `.claude/settings.json` | Hook wiring and a small permission allowlist |
| `CLAUDE.md` | Project rules for the agent, with placeholders |
| `docs/swe/` | Step-by-step guides: `build_feature.md`, `fix_bug.md` |
| `docs/specs/` | Spec template, coverage table, lifecycle rules |
| `dev-notes/adr/`, `dev-notes/plan/` | ADR template and index, execution plan skeleton |
| `.github/ISSUE_TEMPLATE/` | Feature and Bug issue forms that feed `/feature #N` and `/bug #N` |
| `.gitignore` | Secrets, build output, the upstream skills clone |

## The workflow in one screen

```
/feature <brief>|#N    spec from a brief or a GitHub issue, then stop
/feature continue      plan (stop once), build, verify, guard, review, ship, open PR
/feature close         after the merge: live checks, cleanup commands
/feature status        where the branch stands and the next command
/bug <report>|#N       reproduce, failing test, fix, review, PR
/spec <NN>-<slug>      write the spec, stop for approval
/plan                  plan.md and tasks.md from an approved spec
/build                 next task, test first, one commit
/build auto            whole task list after one approval
/quality-review        five-axis review before merge
/constraints guard     catch a weakened quality bar in the diff
/ship                  pre-launch checklist and go/no-go
/constraints           set or check the quality bar in CONSTRAINTS.md
/test                  TDD loop for a single change or bug
```

Branching: `main` always deploys, one short branch per spec (`features/NN-slug`) or fix (`bugs/slug`), one commit per task, squash-merge, own worktree per branch. Spec status moves draft, approved, implemented, superseded. Only an approved spec gets a plan.

## Hooks

All hooks read `.claude/hooks/config.sh`. With the defaults they are safe no-ops until the project has the matching toolchain.

| Hook | Event | Does |
| --- | --- | --- |
| `guard-bash.sh` | PreToolUse Bash | Blocks commit or push on `main`, force push, hard reset, clean. `ALLOW_MAIN_COMMIT=1` bypasses the main check for setup commits. |
| `guard-write.sh` | PreToolUse Edit, Write | Blocks edits to `GENERATED_PATHS`, `.env` files, the upstream skills dir, and `CONSTRAINTS.md` |
| `lint-changed.sh` | PostToolUse Edit, Write | Runs ruff (needs `PY_DIR` and uv) or eslint (needs `JS_DIR` and node_modules) on the saved file |
| `stop-gate.sh` | Stop | Runs `CHECK_CMD` when there are uncommitted changes under `CODE_DIRS` |
| `session-start.sh` | SessionStart | Reports the active spec and open tasks for the current branch |

`config.sh` variables:

```
GENERATED_PATHS="*/frontend/packages/schema/*"   # bash case globs, space-separated
GENERATED_HINT="Change the Pydantic model and run make gen."
CODE_DIRS="backend frontend"
PY_DIR="backend"
JS_DIR="frontend"
CHECK_CMD="make check"
UPSTREAM_SKILLS_DIR="agent-skills"
```

## Keeping projects in sync

The template is the source. When a command, hook or guide improves in one project, port the change here first, then run the installer with `--force --only claude` in the other projects and review the diff. Project-specific files (`CLAUDE.md`, `config.sh`, the plan) are never force-copied in practice: use `--only claude` for the shared parts.

## Upstream and credits

The process layer is built on **[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)** by Addy Osmani, "production-grade engineering skills for AI coding agents", MIT licensed. The license text is in `licenses/agent-skills-MIT.txt`, and `template/.claude/skills/README.md` carries the attribution into each installed project.

Taken from upstream, unchanged unless noted:

- `template/.claude/skills/`: 18 of the 25 skills. Not selected: browser-testing-with-devtools, code-simplification, deprecation-and-migration, doubt-driven-development, idea-refine, performance-optimization, using-agent-skills.
- `template/.claude/agents/`: the three personas. One link fixed to point at `references/orchestration-patterns.md`.
- `template/.claude/references/`: the seven checklists.
- `template/.claude/commands/`: `build`, `plan`, `spec`, `quality-review`, `ship`, `constraints`, `test` started from the upstream commands and were adapted to the spec folder layout and approval gates. `feature` and `bug` are original.

Original to this repo: the hooks, `config.sh`, the SWE guides, the spec and ADR templates, the issue forms and the installer.

Last synced with upstream commit `aeac41d4d005999432bb7312f7ff06383a91d59d` (2026-10-13). To refresh: clone upstream, copy the selected folders from its `skills/`, `agents/` and `references/` over `template/.claude/`, review the diff, update the commit hash here and in `template/.claude/skills/README.md`.
