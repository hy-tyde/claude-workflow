# Build a feature

The path from a one-line task to a deployed feature. "You" is the person driving. "Claude" is a Claude Code session. Example used throughout: team invitations, spec 05.

## Branching rules

- `main` is always deployable. Every merge to `main` deploys to prod. No `develop`, no release branches.
- One short-lived branch per spec, named `features/NN-slug`. Days, not weeks. A spec that needs more than a week is too big and gets split.
- One commit per task on the branch. Squash-merge into `main` with the spec ID in the title, so `main` has one commit per spec and a linear history.
- Open a PR even when nobody else reviews. CI and `/quality-review` run there and the PR links the spec.
- `main` is protected: CI green required, no force-push. No human-review requirement while the team is one developer.
- Unfinished work merges behind a feature flag rather than living on a long branch.
- Migrations have a single head on `main`. CI checks it. Generated files are committed and CI fails on drift.
- Tags mark milestones only.
- Each branch gets its own git worktree, so two Claude sessions never share a checkout.

Commit messages: `type(scope): summary (T003, 05-invitations)`. Squash title: `05-invitations: invite teammates by email with a role`.

## Shortcut

Steps 3 to 12 collapse into three commands:

```
/feature Team invitations: owner invites by email, invitee lands in the workspace with a role
   ... edit the spec, set Status: approved ...
/feature continue        writes plan and tasks, stops once for approval
/feature continue        builds every task, then runs every stage to the PR
   ... squash-merge in GitHub ...
/feature close           confirms the live check, prints the cleanup commands
```

`/feature continue` runs the repo's other commands in this order and records each one in a `## Pipeline` table in `tasks.md`:

| Stage | Command | Stops when |
| --- | --- | --- |
| Plan | `/plan` | always, for your approval |
| Build | `/build auto`, with `/test` inside every task | a test cannot pass, the spec is silent, or the task touches auth, secrets, migrations or deploy |
| Verify | `make test`, `make lint`, `make e2e`, `make eval` | red after one fix attempt |
| Guard | `/constraints guard`, `/constraints check` | the bar was weakened and the fix needs you |
| Review | `/quality-review`, then `/code-review` | never, findings are fixed or listed in the PR |
| Ship | `/ship` for anything beyond a two-file, fifty-line change away from auth, data, config or deploy | NO-GO |
| PR | push, `gh pr create` | always, merging is yours |

`/feature status` prints where the branch stands and the next command.

The long form below is what the command does, and what to run by hand when one step needs attention.

## Steps

### 1. Create the task

One line, in chat or an issue: "Team invitations: owner invites by email, invitee lands in the workspace with a role, week 2." Name the PRD story if it is not obvious.

### 2. Branch and worktree

```
git worktree add ../<repo>-05 -b features/05-invitations main
cd ../<repo>-05 && claude
```

### 3. Spec

```
/spec 05-invitations
```

Claude reads the PRD story and the plan, lists its assumptions, asks the unclear points one at a time, and writes `docs/specs/05-invitations/spec.md` from `docs/specs/_template.md`: user stories with acceptance scenarios, FR and NFR IDs, schema and API changes, golden examples if the feature touches an AI agent, boundaries, success criteria. Adds a row to `docs/specs/coverage.md`. Stops.

### 4. Approve the spec

Read it. Edit it in the IDE. Set `Status: approved`. Commit:

```
git commit -am "spec(05-invitations): approved"
```

If it is wrong, say what is wrong and go back to step 3. Nothing downstream starts on a draft.

### 5. Plan

```
/plan
```

Claude reads the approved spec, `CLAUDE.md`, `CONSTRAINTS.md` and the relevant code. Writes `plan.md` (components, order, risks, checkpoints) and `tasks.md` (T001.., each with acceptance criteria, verification command, files, size). Stops.

### 6. Approve the plan

Read `tasks.md`. Reorder, cut, or split tasks. Say "approve". Hedged answers do not count. Claude commits the plan as its own commit.

### 7. Build

```
/build auto
```

For each task in order Claude runs the `/test` loop: writes a failing test named after the FR it covers, writes the minimum code, runs `make test`, `make lint` and the build, commits as `feat(invitations): ... (T003, 05-invitations)`, ticks the task. AI agent tasks also need the evals green.

Claude stops and asks only when a test will not pass, the spec is silent on a decision, or the task touches auth, secrets, migrations beyond the spec, or deploy. After you answer, run `/build auto` again and it resumes from the next open task.

To watch each task, use `/build` without `auto`. One task per call.

### 8. Guard, review, ship

```
/constraints guard
/constraints check
/quality-review
/code-review
/ship
```

Guard inspects the branch diff for a weakened bar: lowered thresholds, skipped or deleted tests, new suppression comments, stubs. Check runs `CONSTRAINTS.md` against the branch; without that file it is a reminder to run `/constraints`. Review covers five axes: correctness, readability, architecture, security, performance. Claude fixes what it finds, then the built-in `/code-review` gives a second opinion. Ship fans out to the code reviewer, security auditor and test engineer and ends in a GO or NO-GO with a rollback plan; it is skipped only for a change under two files and fifty lines that touches none of auth, data access, migrations, config or deploy. Read the summaries and only the files they flag.

### 9. Open the PR

```
git push -u origin features/05-invitations
gh pr create --title "05-invitations: invite teammates by email with a role" --body-file /tmp/pr.md   # Spec: docs/specs/05-invitations/spec.md, Closes #<issue>, tests, guard, review, ship decision
```

CI runs lint, tests, codegen drift, migration head check, build. The PR body carries the spec link, `Closes #<issue>`, the tests added with their results, the guard result, the review findings fixed and left open, and the ship decision. Red CI means back to step 7.

### 10. Merge

Squash-merge in GitHub. The merge triggers the deploy.

### 11. Verify live

Open the prod URL and do what the spec promised. For AI features also open the tracing tool and check the last traces for cost and latency. If it is broken: `make deploy tag=<previous sha>` or a revert commit on `main`.

### 12. Close

```
/feature close
```

Claude checks that the PR is merged, runs the live checks from the spec's success criteria (asking you to confirm the ones that need a browser), turns a failed check into a `/bug` line, and prints the cleanup:

```
cd <main checkout> && git pull && git worktree remove ../<repo>-05 && git branch -d features/05-invitations
```

`Status: implemented` was set with the PR in step 9, so the squash merge carries it to `main`.

If a decision was made that the plan did not cover, the ADR was written in step 7 and merged with the feature.

## What the hooks enforce

`.claude/hooks/` run on every session, independent of what the prompt says. Project paths live in `.claude/hooks/config.sh`.

| Hook | Blocks or does |
| --- | --- |
| `guard-bash.sh` | commit or push on `main`, force push, hard reset, clean |
| `guard-write.sh` | edits to generated paths (`GENERATED_PATHS`), `.env`, the upstream skills dir, `CONSTRAINTS.md` without the user asking |
| `lint-changed.sh` | runs ruff or eslint on each saved file, feeds errors back |
| `stop-gate.sh` | runs `CHECK_CMD` before a turn ends with uncommitted code in `CODE_DIRS` |
| `session-start.sh` | tells a new session the active spec and open tasks |

Setup commits that belong on `main` (plan, docs, ADRs) are made with `ALLOW_MAIN_COMMIT=1 git commit ...`.

## Time budget

For a medium feature at 15 to 20 hours a week of attention:

| Steps | Your time | Claude runs unattended |
| --- | --- | --- |
| 3 to 4 spec | about 1 h | |
| 5 to 6 plan | about 15 min | |
| 7 build | | 1 to 3 h |
| 8 to 11 review, merge, verify | about 30 min | |

Two to four features a week is realistic once the environment exists. Steps 2, 9 and 12 are the only ones with git commands. Everything else is one slash command.
