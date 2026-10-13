# Spec <ID>: <Feature name>

Status: draft | approved | implemented | superseded
PRD: <section or user story quoted from docs/prd/PRD.md>
Week: <schedule week from dev-notes/plan/01-execution-plan.md>
Design: <frame link, if any>

## Objective

What we build and why, in three sentences. Who uses it. What success looks like.

## Assumptions

Listed before anything else. The reviewer corrects these first.

1. ...

## User stories

Ordered by priority. P1 is the thin slice that must ship alone.

### US-1 (P1): <title>

As a <role>, I want <...> so that <...>.

Acceptance scenarios:

- Given <state>, when <action>, then <observable result>.
- Given <state>, when <action>, then <observable result>.

### US-2 (P2): <title>

...

## Requirements

Each line gets an ID. Tests and tasks reference the ID.

- FR-001: The system MUST ...
- FR-002: The system MUST ...
- NFR-001: <latency, availability or cost target with a number>
- NFR-002: <tenancy or data isolation rule, with a test per new endpoint>

## Schema and API changes

Models touched (source of truth), new tables or columns, new endpoints with request and response shapes. "None" is a valid answer.

## Agent behaviour (only for AI features)

Golden examples written before the prompt. Three to five pairs of input and expected output, plus tone constraints. They become the eval fixtures.

| Input | Expected output | Must not |
| --- | --- | --- |
| ... | ... | ... |

## Out of scope

What this spec deliberately does not do, so nobody builds it by accident.

## Boundaries

- Always: run `make test` and `make lint` before a commit. <project-wide invariants>
- Ask first: schema changes beyond this spec, new dependencies, CI changes, anything touching auth or secrets.
- Never: hand-edit generated files, commit secrets. <project-specific nevers>

## Success criteria

Specific and testable. These become test names.

- [ ] FR-001 covered by `tests/...::test_...`
- [ ] End-to-end flow <name> passes
- [ ] Live check on prod: ...

## Open questions

Resolved before status becomes approved. Use `/interview-me` style questioning if the list is long.

- ...
