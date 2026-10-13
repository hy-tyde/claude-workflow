---
description: Start spec-driven development — write a structured specification before writing code
---

Invoke the spec-driven-development skill.

Begin by understanding what the user wants to build. Ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

Then generate a structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries.

If the request bundles several independently testable capabilities, first propose a capability map (module ids, dependency direction, build order) per the skill's Phase 0 and get it approved, then spec each module in dependency order.

Use `docs/specs/_template.md` as the structure (user stories with acceptance scenarios, FR/NFR IDs, schema and API changes, golden examples for agent features, boundaries, success criteria). Pick the next free number and save to `docs/specs/<NN>-<slug>/spec.md` with status `draft`. Add a row to `docs/specs/coverage.md`. Never write `SPEC.md` at the repo root. Confirm with the user and stop; planning starts in a later turn after the status is set to `approved`.
