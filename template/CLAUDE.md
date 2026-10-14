# <Project name>

<One paragraph: what the product is, who it is for, the next milestone and its date, team size.>

## Read first

- `dev-notes/plan/01-execution-plan.md`: stack, repo shape, workflow, schedule. The source for every decision until ADRs exist.
- `docs/prd/PRD.md`: scope. `docs/architecture/`: diagrams.
- `docs/specs/`: one folder per feature. `dev-notes/adr/`: decisions. `CONSTRAINTS.md`: quality bar, once `/constraints` has run.

## Workflow

`/feature <brief>` writes the spec and stops. `/feature continue` runs plan (stop for approval), build, test, constraints, review, ship and the PR. `/feature close` after the merge. Long form: `/spec`, `/plan`, `/build` or `/build auto`, `/test`, `/constraints guard`, `/quality-review`, `/code-review`, `/ship`. Specs live in `docs/specs/<NN>-<slug>/` as `spec.md`, `plan.md`, `tasks.md`, never `SPEC.md` at the root. Step-by-step: `docs/swe/build_feature.md` and `docs/swe/fix_bug.md`. Branches: `features/NN-slug` or `bugs/slug` from `main`, one commit per task, squash-merge, never commit directly to `main` for feature or fix work.

## Commands

Everything runs through `make` (targets listed in the plan). Until the Makefile exists, say so instead of inventing commands.

## Rules

<Project rules the agent must follow. Keep each one checkable. Examples:>

- <Source of truth for the data model and how generated code is produced; never hand-edit generated files.>
- <Tenancy rule: every query on tenant data filters by the tenant id, and each new endpoint gets a test for it.>
- <Prompts, configs or other artifacts that must be versioned files, never inline.>
- Dev and demo data is synthetic, from `make seed` only.
- Check third-party library usage against current docs before writing it (`source-driven-development`).
- No new infrastructure component without an ADR.

## Boundaries

- Ask first: schema changes outside the current spec, new dependencies, CI or compose changes, anything touching auth, secrets or deploy.
- Never: commit `.env`, weaken `CONSTRAINTS.md`, delete or skip a failing test to get green, edit `agent-skills/` (upstream copy, selected skills live in `.claude/skills/`).
