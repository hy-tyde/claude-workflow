# Fix a bug

The path from a bug report to a verified fix. The rule that makes it work: no fix without a failing test that reproduces the bug first. Claude's `/test` command calls this the Prove-It pattern.

## Branching rules

Same as `build_feature.md`, with a `bugs/` prefix: `bugs/short-slug`, from `main`, squash-merged, one commit on `main`. A bug found while building a spec is fixed on that spec's branch as a task, not on a separate branch.

## Shortcut

Steps 3 to 8 collapse into one command on a `bugs/<slug>` branch:

```
/bug user typed "next Tuesday", date field saved null; expected the coming Tuesday; seed account, item 4; seen on prod 2026-11-20, trace abc123
```

It stops if it cannot reproduce, if the failing test will not fail, or if the fix needs a schema change, a dependency, or touches auth. The long form below is what it does.

## Steps

### 1. Report

Write the bug down before touching anything. Four lines:

```
What happened: user typed "next Tuesday", the date field saved null
Expected: the date of the coming Tuesday
How to reproduce: seed account, open item 4, type "next Tuesday"
Where seen: prod, 2026-11-20, trace abc123
```

Decide the path. A bug that blocks a customer on prod is a hotfix: same steps, done now, review kept short. Everything else waits for the next working session.

### 2. Branch and worktree

```
git worktree add ../<repo>-fix -b bugs/parse-relative-dates main
cd ../<repo>-fix && claude
```

### 3. Reproduce and find the root cause

Paste the report into the session. Claude follows the `debugging-and-error-recovery` skill: reproduce first, then trace the cause, then fix. If it cannot reproduce, it says so and stops. No speculative fixes.

For AI agent bugs the reproduction is a golden example: the input and the expected output go into the eval fixtures of the skill that failed, before the prompt or code is touched.

### 4. Prove it

```
/test
```

Claude writes a test that reproduces the bug. The test must fail. Claude shows the failure. If the test passes, the bug is not understood yet, back to step 3.

The test name says what it protects:

```
test_parse_relative_weekday_returns_next_occurrence_FR_012
```

### 5. Fix

Claude writes the smallest change that makes the test pass, runs the full suite for regressions, runs `make lint`, and commits:

```
fix(dates): parse relative weekdays to the next occurrence (bugs/parse-relative-dates)
```

If the fix needs a schema change, a new dependency, or touches auth, Claude asks before continuing.

### 6. Check the spec

If the spec that owns the behaviour was wrong or silent, Claude updates the spec in the same commit. The spec changes first, the code follows. A bug that no spec covers gets a line in the nearest spec's requirements.

### 7. Review

```
/quality-review
```

For a hotfix, a one-file diff and a passing test is enough. For a larger fix, also run `/code-review`.

### 8. PR, merge, deploy

```
git push -u origin bugs/parse-relative-dates
gh pr create --title "fix: parse relative weekdays to the next occurrence" --body "Report: <link or the four lines>. Test: tests/test_parse.py::test_parse_relative_weekday_returns_next_occurrence_FR_012"
```

Squash-merge. Deploy runs. Rollback is `make deploy tag=<previous sha>` if the fix makes it worse.

### 9. Verify live

Repeat the reproduction on prod. For AI agent bugs, check the new trace. Confirm in the PR with one line.

### 10. Close

Remove the worktree and branch. If the bug reached a customer, add one line to `docs/swe/incidents.md`: date, what, cause, fix, what would have caught it earlier. That line is the input for the next `/constraints` review.

## What not to do

- No fix without a failing test first.
- No "while I am here" refactors in a fix branch. Open a spec for those.
- No skipping or deleting a test to get to green. `CONSTRAINTS.md` forbids it and `/constraints guard` catches it.
- No fix for a bug you cannot reproduce. Add logging, deploy that, wait for the next occurrence.
