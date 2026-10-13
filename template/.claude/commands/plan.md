---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the planning-and-task-breakdown skill.

Read the spec the user names, or the newest `docs/specs/<NN>-<slug>/spec.md` with status `approved` (refuse to plan a `draft`), plus `CLAUDE.md`, `CONSTRAINTS.md` if present, and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to `docs/specs/<NN>-<slug>/plan.md` and the task list to `docs/specs/<NN>-<slug>/tasks.md`. Task IDs are `T001`, `T002`, ... and each task names the FR/US IDs it covers and the files it touches.

If that folder already has a `tasks.md` with unchecked tasks, stop and ask before writing — never silently overwrite an incomplete plan.
