---
description: Run the feature pipeline end to end. "/feature <brief>" or "/feature #<issue>" writes the spec and stops. "/feature continue" runs the next stage and every stage after it that needs no approval: plan, build, test, constraints, review, ship, PR. "/feature close" after the merge. "/feature status" shows where the branch stands.
---

$ARGUMENTS

Read `docs/swe/build_feature.md` first. It is the contract for this command. This command only sequences the repo's other commands and decides where to stop. It never replaces a stage with its own shortcut.

## The pipeline

| # | Stage | Runs | Leaves behind | Stops |
| --- | --- | --- | --- | --- |
| 1 | Spec | `.claude/commands/spec.md` | `docs/specs/NN-slug/spec.md` (draft), row in `coverage.md`, commit `spec(NN-slug): draft` | always: user sets `Status: approved` |
| 2 | Plan | `.claude/commands/plan.md` | `plan.md`, `tasks.md` with a `## Pipeline` table, commit `plan(NN-slug): tasks` | always: user approves the task list |
| 3 | Build | `.claude/commands/build.md` in `auto` mode, `.claude/commands/test.md` inside every task | one `feat(scope): ... (Txxx, NN-slug)` commit per task, ticked task | only on the stop conditions in `build.md` |
| 4 | Verify | `make test`, `make lint`, `make e2e` if the target exists, `make eval` if the target exists and any task touched the AI agent code | nothing new, or fix commits `fix(scope): ... (NN-slug)` | if red after one fix attempt: back to 3 |
| 5 | Guard | `.claude/commands/constraints.md guard`, then `constraints.md check` when `CONSTRAINTS.md` exists | fix commits `chore(NN-slug): ...` | if the bar was weakened and the fix is not obvious |
| 6 | Review | `.claude/commands/quality-review.md`, then the built-in `code-review` skill on the branch diff against `main` | commit `review(NN-slug): <what was fixed>` | never; findings are fixed or listed in the PR |
| 7 | Ship | `.claude/commands/ship.md` when the change is not small (see below) | the GO or NO-GO block saved into the PR body | on NO-GO |
| 8 | PR | `Status: implemented`, coverage row, push, `gh pr create` | commit `spec(NN-slug): implemented`, open PR | always: merging is the user's action |
| 9 | Close | `/feature close` | live check confirmed, cleanup commands printed | end |

Every stage ticks its row in the `## Pipeline` table of `tasks.md` (write `done YYYY-MM-DD` in the Status column, never a `- [ ]` checkbox: the hooks count those as open tasks). `/feature continue` reads that table to find where it is.

## Mode A: `/feature <brief>` or `/feature #<issue>` (arguments do not start with `continue`, `close` or `status`)

0. If the argument is an issue number, read it: `gh issue view <n> --json title,body,labels`. The body's Brief, PRD story, Plan week and Design frame fields feed the spec header and objective. Put `Issue: #<n>` in the spec header and `Closes #<n>` in the PR body later. If `gh` fails, ask the user to paste the issue text.
1. Confirm the branch: `git branch --show-current` must be `features/NN-slug`. If it is `main`, stop and tell the user to create the branch and worktree (step 2 of the guide). Never create the branch yourself on `main`'s checkout.
2. Invoke the `spec-driven-development` skill with the brief. Follow `.claude/commands/spec.md` exactly: assumptions first, clarifying questions one at a time, capability map if the brief bundles several capabilities, then `docs/specs/NN-slug/spec.md` with status `draft`, a row in `docs/specs/coverage.md`.
3. Commit the spec as `spec(NN-slug): draft`.
4. Summarise, list open questions, and STOP. Tell the user: edit the spec, set `Status: approved`, then run `/feature continue`.

## Mode B: `/feature continue`

Find the spec for the current branch: `docs/specs/<NN-slug>/spec.md` where `NN-slug` is the branch name after `features/`. If its status is not `approved` (or `implemented` with an open PR), stop and say so. Then run the first stage below whose condition holds, and keep going until a stage stops.

### Stage 2: no `plan.md` or `tasks.md`

Invoke `planning-and-task-breakdown` as `.claude/commands/plan.md` describes. Append this table to `tasks.md`:

```
## Pipeline

| Stage | Command | Status |
| --- | --- | --- |
| Plan | /plan | done YYYY-MM-DD |
| Build | /build auto | open |
| Verify | make test, make lint, make e2e, make eval | open |
| Guard | /constraints guard, /constraints check | open |
| Review | /quality-review, /code-review | open |
| Ship | /ship | open |
| PR | gh pr create | open |
| Close | /feature close | open |
```

Commit as `plan(NN-slug): tasks`. Present the task list and STOP for approval. The user re-runs `/feature continue` to proceed; that re-run is the approval.

### Stage 3: `tasks.md` has an open `- [ ] Txxx` line

Run `.claude/commands/build.md` in `auto` mode. Treat the previous approval of the task list as the single approval. Inside every task, the red-green-refactor loop is `.claude/commands/test.md` for new features: the failing test is named after the FR or US ID it covers, and it fails before any implementation. Agent tasks also need `make eval` green and their golden examples in the spec before the prompt is written. A task that adds a dependency or an infrastructure component, or reverses a plan decision, stops for the user as `build.md` says, then writes the ADR with `documentation-and-adrs` in the same commit once approved. Stop only for the conditions `build.md` lists. When every task is ticked, mark Build `done` and fall through.

### Stage 4: Verify

Run `make test` and `make lint`. Run `make e2e` if the Makefile has that target. Run `make eval` if the Makefile has that target and any commit on the branch touched the AI agent code (the directory `CLAUDE.md` names). Red means one targeted fix attempt following `debugging-and-error-recovery`, committed as `fix(scope): ... (NN-slug)`. Still red: STOP and report the output. Never skip, delete or mark a test as expected failure to get green. Green: mark Verify `done`.

### Stage 5: Guard

Run `.claude/commands/constraints.md` with `guard` on the branch diff against `main`: lowered thresholds, skipped or deleted tests, new suppression comments, stubs, new exceptions. If `CONSTRAINTS.md` exists, also run it with `check`. Fix what you find and commit as `chore(NN-slug): ...`. If a finding needs the user (a threshold that is genuinely wrong, an exception that needs an owner), STOP. If `CONSTRAINTS.md` does not exist, write `done (no CONSTRAINTS.md)` and remind the user to run `/constraints`. Otherwise mark Guard `done`.

### Stage 6: Review

Run `.claude/commands/quality-review.md` on the branch diff against `main`. Fix Critical and Required findings. Then run the built-in `code-review` skill on the same diff for a second opinion and fix confirmed correctness findings. Commit as `review(NN-slug): <what was fixed>`. Optional and Nit findings that were not fixed go into the PR body. Re-run `make test` and `make lint` after the fixes. Mark Review `done`.

### Stage 7: Ship

Skip `/ship` only if all of these hold: the branch diff touches 2 files or fewer, is under 50 lines, and touches none of auth, payments, data access, migrations, config, env, compose or deploy. Then write `done (skipped: small change)`. Otherwise run `.claude/commands/ship.md`. On GO, mark Ship `done` and keep the decision block for the PR body. On NO-GO, fix the blockers if they are code, commit, and run it again; if a blocker needs the user, STOP with the decision block.

### Stage 8: PR

1. Set `Status: implemented` in the spec and `implemented` in the spec's row of `docs/specs/coverage.md`. Mark PR `done`. Commit as `spec(NN-slug): implemented`.
2. Push and open the PR:
   `git push -u origin features/NN-slug`
   `gh pr create --title "NN-slug: <spec objective in under 10 words>" --body-file <file>`
   The body has, in this order: `Spec: docs/specs/NN-slug/spec.md`, `Closes #<n>` if there was an issue, tests added (names and count) with the `make test`, `make lint`, `make e2e` and `make eval` results, the Guard result, the Review findings fixed and the ones left open, the Ship decision block or the reason it was skipped.
   If `gh` is not authenticated, print the two commands and stop.
3. Summarise: tasks done, tests added, commits, anything skipped or flagged. STOP. Merging is the user's action. Tell the user: squash-merge in GitHub, then run `/feature close` in this worktree.

## Mode C: `/feature close`

1. `gh pr view --json state,mergedAt,url` for the current branch. If the state is not `MERGED`, stop and say so.
2. Read the `Live check` lines under Success criteria in the spec. If the Makefile has a `deploy-check` target, run it. For each live check that needs a browser or a human, ask the user to confirm it, one question at a time. For agent features also ask the user to confirm the last traces in the tracing tool show cost and latency.
3. Any failed live check becomes a bug: print `/bug <what happened, expected, how to reproduce, where seen>` with the fields filled from the check, and stop. Do not fix it on the merged feature branch.
4. All live checks pass: print the cleanup commands and stop. The worktree cannot remove itself.
   `cd <main checkout> && git pull && git worktree remove ../<repo>-NN && git branch -d features/NN-slug`

## Mode D: `/feature status`

Print the branch, the spec status, the task counts (`- [x] Txxx` versus `- [ ] Txxx`), the `## Pipeline` table, and the PR state from `gh pr view` if one exists. Then the single next command to run. No changes.

## Never

- Commit or push on `main`.
- Weaken `CONSTRAINTS.md`, skip or delete a failing test, or mark one as expected failure to pass a stage.
- Continue past a stop condition because the user said "auto" or "continue" earlier.
- Replace a stage's command with an inline summary of what it would have done. If a command cannot run (missing tool, missing `make` target), write that in the Pipeline table and the PR body.
