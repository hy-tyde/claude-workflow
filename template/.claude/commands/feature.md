---
description: Run the feature pipeline. "/feature <brief>" writes the spec and stops. "/feature continue" plans, builds, reviews and opens the PR, pausing once for plan approval.
---

$ARGUMENTS

Read `docs/swe/build_feature.md` first. It is the contract for this command.

## Mode A: `/feature <brief>` or `/feature #<issue>` (arguments do not start with `continue`)

0. If the argument is an issue number, read it: `gh issue view <n> --json title,body,labels`. The body's Brief, PRD story, Plan week and Figma fields feed the spec header and objective. Put `Issue: #<n>` in the spec header and `Closes #<n>` in the PR body later. If `gh` fails, ask the user to paste the issue text.
1. Confirm the branch: `git branch --show-current` must be `features/NN-slug`. If it is `main`, stop and tell the user to create the branch and worktree (step 2 of the guide). Never create the branch yourself on `main`'s checkout.
2. Invoke the `spec-driven-development` skill with the brief. Follow `.claude/commands/spec.md` exactly: assumptions first, clarifying questions one at a time, capability map if the brief bundles several capabilities, then `docs/specs/NN-slug/spec.md` with status `draft`, a row in `docs/specs/coverage.md`.
3. Commit the spec as `spec(NN-slug): draft`.
4. Summarise, list open questions, and STOP. Tell the user: edit the spec, set `Status: approved`, then run `/feature continue`.

## Mode B: `/feature continue`

1. Find the spec for the current branch: `docs/specs/<NN-slug>/spec.md` where `NN-slug` is the branch name after `features/`. If its status is not `approved`, stop and say so.
2. If `plan.md` or `tasks.md` is missing, invoke `planning-and-task-breakdown` as `.claude/commands/plan.md` describes. Commit them as `plan(NN-slug): tasks`. Present the task list and STOP for approval. The user re-runs `/feature continue` to proceed.
3. If `tasks.md` exists and has open tasks, run `.claude/commands/build.md` in `auto` mode. Treat the previous approval of the task list as the single approval. Stop only for the conditions `build.md` lists.
4. When every task is ticked, run `.claude/commands/quality-review.md` on the branch diff against `main`. Fix findings. Commit as `review(NN-slug): ...`.
5. Run `make test` and `make lint`. Both green or go back to step 3.
6. Push and open the PR:
   `git push -u origin features/NN-slug`
   `gh pr create --title "NN-slug: <spec objective in under 10 words>" --body "Spec: docs/specs/NN-slug/spec.md"`
   If `gh` is not authenticated, print the two commands and stop.
7. Set `Status: implemented` in the spec, commit, push. Summarise: tasks done, tests added, commits, anything skipped or flagged. STOP. Merging is the user's action.

## Never

- Commit or push on `main`.
- Weaken `CONSTRAINTS.md`, skip or delete a failing test.
- Continue past a stop condition because the user said "auto" earlier.
