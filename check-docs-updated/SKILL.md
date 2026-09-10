---
name: check-docs-updated
description: Checks whether repository docs, plans, examples, runbooks, changelogs, generated docs, or other durable written artifacts match a code or configuration change. Use when asked to verify or update docs, prevent documentation drift, or check whether a PR needs documentation changes.
---

# Check docs updated

Check that the repository's written artifacts still match what the branch changes. This skill covers files in the repo. PR title and body belong to `writing-pr-descriptions`.

## Rules

- The target is the current PR or branch diff unless the user names another PR, range, or file set.
- Take the base SHA from the PR host when there is a PR; otherwise use the merge-base with the tracked upstream or remote default branch.
- Follow the repository's doc and plan conventions: `AGENTS.md`, contribution docs, existing `docs/plans/` files, and generated-doc workflows.
- Edit files only when asked to update, fix, prepare, or carry the branch forward. When asked only to check, report.
- Use `drafting-plans` when a `docs/plans/` file covers the work or the change affects plan scope, sequencing, validation, decisions, or open questions.

## Workflow

1. Resolve the target: repo, branch, base and head SHA. Note unrelated dirty files. Read the diff.

2. List what changed that a reader could depend on: behavior, setup, commands, config, environment variables, outputs, APIs, operational procedures, examples, migrations, and user-visible strings. Read the changed tests, examples, and nearby docs for the intended contract.

3. Find the docs that describe those things. Look in `docs/`, `docs/plans/`, READMEs, examples, runbooks, changelogs, migration notes, CLI help snapshots, API references, generated docs, and package-level docs. Search for the exact commands, config keys, env vars, symbols, flags, plan names, and strings the diff added or removed. If the repository has no relevant docs, say so rather than inventing a requirement.

4. Decide. Docs need updating when anything from step 2 changed and a doc describes it. A plan needs updating when a slice landed, scope changed, the implementation diverged, validation changed, a decision was made, or an open question was answered. Internal refactors, tests-only changes, and renames behind unchanged public contracts usually need nothing.

5. Fix when authorized. Make the smallest accurate edit. Match the surrounding doc's register, person, and heading style, and write the instruction the reader follows ("Run `make sync`"), not a description of it. Otherwise follow `writing-plainly`. For generated docs, change the source and regenerate. Run the validation that covers changed docs, generated files, examples, or loaders. Keep unrelated dirty files out.

## Output

Start with a status line, then a short paragraph for each item that has content.

- Check: `Status: current | needs-update | not-required | blocked`, then the findings, which files should change or why none need to, and anything deferred.
- Fix: `Status: updated | not-required | blocked`, then the files changed, validation run and results, and any remaining risk.
