---
name: check-docs-updated
description: Checks whether repository docs, plans, examples, runbooks, changelogs, generated docs, or other durable written artifacts match a code or configuration change. Use when asked to verify or update docs, prevent documentation drift, or check whether a PR needs documentation changes.
---

# Check Docs Updated

Verify that durable repository documentation matches what the branch actually changes. Keep this focused on files in the repo; use `check-pr-description` for PR title and body text.

## Operating Contract

- Treat the current PR or branch diff as the target unless the user names a different PR, commit range, or file set.
- Use a fresh base SHA: PR base from the host when reviewing a PR, otherwise merge-base with the tracked upstream or remote default branch.
- Respect repository doc and plan conventions from `AGENTS.md`, contribution docs, existing `docs/plans/` files, and generated-doc workflows.
- Preserve caller, platform, or connector-required output formats.
- Do not edit files unless the user asked to update, fix, prepare, or carry the branch forward. When only asked to check, report findings.
- Keep PR title/body changes out of this skill; if PR metadata is stale, hand off to `check-pr-description`.

## Companion Skills

- Use `drafting-plans` when a `docs/plans/` file exists for the work or the change affects plan scope, sequencing, validation, decisions, or open questions.
- Use `humanizing-text` when rewriting substantial public-facing docs so the result stays concise and natural.

## Workflow

1. Resolve the target.
   - Identify repo, branch, base SHA, and head SHA.
   - Inspect `git status` and record unrelated dirty files.
   - Read the diff from base to head.

2. Build the branch truth.
   - Summarize changed behavior, setup, commands, config, env vars, outputs, APIs, operational procedures, examples, migrations, and user-visible strings.
   - Inspect changed tests, examples, and nearby docs to understand the intended contract.

3. Find relevant docs.
   - Check `docs/`, `docs/plans/`, README files, examples, runbooks, changelogs, migration notes, CLI help snapshots, API references, generated docs, and package-level documentation that match changed behavior.
   - Use targeted searches for renamed commands, config keys, env vars, API symbols, feature flags, plan names, and user-visible strings introduced or removed by the diff.
   - If the repo has no relevant doc tree, say so explicitly instead of manufacturing a docs requirement.

4. Decide whether docs are required.
   - Docs are required when behavior, setup, commands, config, outputs, APIs, operational procedures, examples, migrations, troubleshooting guidance, or developer-facing contracts change.
   - Plan updates are required when a slice is completed, scope changes, implementation diverges from the plan, validation changes, decisions are made, or open questions are resolved.
   - Docs are usually not required for internal-only refactors, tests-only changes, mechanical renames hidden behind unchanged public contracts, or private cleanup with no durable plan.

5. Fix when authorized.
   - Patch the smallest accurate docs or plan update.
   - If docs are generated, update the source and regenerate instead of editing generated output by hand.
   - Run relevant validation for changed docs, generated artifacts, examples, or loaders.
   - Keep unrelated dirty files out of the patch.

## Output

For a check-only pass, report:

1. `Status: current | needs-update | not-required | blocked`
2. Docs/plans findings, if any.
3. Files that should change or why no docs are required.
4. Evidence checked and any deferred areas.

For a fix pass, report:

1. `Status: updated | not-required | blocked`
2. Docs/plans files changed.
3. Validation commands and results.
4. Remaining risks or follow-ups.
