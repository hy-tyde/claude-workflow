# Specs

One folder per feature: `docs/specs/<NN>-<slug>/` holding `spec.md` (what and why), `plan.md` (how), `tasks.md` (ordered work). Start from `_template.md`.

Lifecycle: draft, approved, implemented, superseded. Only approved specs get a plan. A spec is updated, not bypassed, when implementation deviates.

Commands: `/spec` writes the spec and stops. `/plan` writes plan and tasks after approval. `/build` implements the next task, `/build auto` runs the whole task list after one approval. `/quality-review` before merge. `/ship` before a deploy that carries risk.

Coverage: `coverage.md` maps each PRD user story to the spec that covers it. Updated when a spec reaches approved.
