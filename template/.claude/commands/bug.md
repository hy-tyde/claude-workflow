---
description: Run the bug pipeline on a bugs/<slug> branch. "/bug <report>" reproduces, proves with a failing test, fixes, reviews and opens the PR. Stops when it cannot reproduce.
---

$ARGUMENTS

Read `docs/swe/fix_bug.md` first. It is the contract for this command.

## Steps

1. **Branch check.** `git branch --show-current` must be `bugs/<slug>`. On `main` or a `features/` branch, stop and tell the user: a bug found while building a spec is a task on that spec's branch, otherwise create `git worktree add ../<repo>-fix -b bugs/<slug> main`.
2. **Report.** If the argument is `#<n>`, read it with `gh issue view <n> --json title,body` and take the four lines from the template fields; the PR body gets `Closes #<n>`. Otherwise turn the arguments into the four lines: what happened, expected, how to reproduce, where seen. If any line cannot be filled from the arguments or the code, ask for it, one question at a time, then stop until answered. Save the report at the top of the PR body later.
3. **Reproduce.** Invoke `debugging-and-error-recovery`. Reproduce locally with `make up` or a focused test. Trace the root cause. If it cannot be reproduced, say so, propose the logging that would catch it next time, and STOP. No speculative fix.
4. **Prove it.** Invoke `test-driven-development` in Prove-It mode: write one test named `test_<behaviour>_<FR id if known>` that fails on the bug. Show the failure. If the test passes, the cause is not understood, back to step 3. For agent bugs, the reproduction is a golden example added to the eval fixtures of the skill that failed, before any prompt or code changes.
5. **Fix.** Smallest change that makes the test pass. Full `make test`, `make lint`. Commit as `fix(<scope>): <summary> (bugs/<slug>)`. Ask first if the fix needs a schema change, a new dependency, or touches auth or secrets.
6. **Spec check.** If a spec in `docs/specs/` owns the behaviour and was wrong or silent, update it in the same commit. If nothing covers it, add one requirement line to the nearest spec.
7. **Review.** Run `.claude/commands/quality-review.md` on the diff. A one-file fix with a passing test needs no more. Fix findings.
8. **PR.** `git push -u origin bugs/<slug>` then `gh pr create --title "fix: <summary>" --body "<four-line report>\n\nTest: <path>::<name>"`. If `gh` is not authenticated, print the commands and stop.
9. **Summarise and STOP**: cause, test, fix, files, anything flagged. Merging and the live check are the user's.

## Never

- Fix without a failing test first.
- Refactor "while here". Note it for a spec instead.
- Skip or delete a test to get green.
- Touch `main`.
