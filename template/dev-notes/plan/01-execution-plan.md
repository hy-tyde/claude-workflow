# Execution plan

The single source for stack, repo shape, workflow and schedule until ADRs exist. Replace every section.

## 1. Stack

<Languages, frameworks, database, hosting. One line each with the reason.>

## 2. Repo shape

<Top-level directories and what lives in each. Which paths are generated.>

### 2.3 Make targets

```
make up        start everything locally
make down
make test      all tests
make lint      all linters and type checks
make check     fast checks the stop hook runs (lint + related tests, under 90 s)
make seed      synthetic dev data
make deploy    what CI runs on push to main
```

## 3. Workflow

See `docs/swe/build_feature.md` and `docs/swe/fix_bug.md`.

## 4. Schedule

<Week-by-week list of specs to deliver.>
