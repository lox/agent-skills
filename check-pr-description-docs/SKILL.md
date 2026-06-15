---
name: check-pr-description-docs
description: Check whether a pull request description still matches the actual diff and whether relevant plans, docs, examples, runbooks, or changelogs have been updated. Use when asked to check or update PR descriptions, make sure docs or plans are current, verify documentation drift before review or merge, or prepare a PR for a final readiness pass.
---

# Check PR Description and Docs

Verify that a PR's public explanation and supporting docs still match what the branch actually changes. Prefer concrete drift findings over broad writing advice.

## Operating Contract

- Treat the current PR as the target when one exists; otherwise use the branch diff and any draft PR body the user supplied.
- Use fresh PR metadata from the host when available: title, body, base SHA, head SHA, changed files, and comments that materially changed scope.
- Respect repository PR-description conventions from `AGENTS.md`, contribution docs, or prior PRs. Do not add noisy sections that the repo discourages.
- Preserve caller, platform, or connector-required output formats.
- Do not edit files or PR text unless the user asked to update, fix, prepare, or carry the PR forward. When only asked to check, report findings.
- Keep unrelated dirty worktree changes out of any docs or PR-body updates.

## Companion Skills

- Use `drafting-plans` when a `docs/plans/` file exists for the work or the PR changes plan scope, sequencing, validation, decisions, or open questions.
- Use `humanizing-text` when rewriting substantial PR descriptions or public-facing docs so the result stays concise and human.
- Use PR workflow skills such as `babysitting-prs` or `handling-codex-reviews` only when review comments, CI, or Codex state are part of the user's request.

## Workflow

1. Resolve the target.
   - Identify repo, PR number, branch, base SHA, and head SHA.
   - Fetch the PR title and body from GitHub or the relevant host.
   - Inspect `git status` and record unrelated dirty files.

2. Build the branch truth.
   - Read the diff from the PR base SHA to head.
   - Inspect changed files plus nearby docs, examples, config, tests, and user-facing surfaces.
   - Summarize what actually changed: motivation, behavior, interfaces, config, migrations, validation, risks, and rollout impact.

3. Check the PR description.
   - Confirm it describes the real problem or motivation, not just a changelog.
   - Confirm it mentions user or developer impact when behavior, workflow, config, APIs, or output changed.
   - Confirm examples are current when commands, config, UI text, generated output, or APIs changed.
   - Remove or flag stale claims, obsolete validation notes, outdated screenshots, wrong file names, old scope, and fixed risks presented as still open.
   - Keep implementation detail limited to what reviewers need to understand.

4. Find relevant docs and plans.
   - Check `docs/`, `docs/plans/`, README files, examples, runbooks, changelogs, migration notes, CLI help snapshots, API references, and generated docs that match changed behavior.
   - Use targeted searches for renamed commands, config keys, env vars, API symbols, feature flags, plan names, and user-visible strings introduced or removed by the diff.
   - Treat docs as not required only when the change is internal-only and no plan, user workflow, public API, operational procedure, or developer-facing contract changed.

5. Decide what must change.
   - Plans should be updated when a slice is completed, scope changes, implementation diverges from the plan, validation changes, or open questions are resolved.
   - Docs should be updated when behavior, setup, commands, config, outputs, APIs, operational procedures, examples, or troubleshooting guidance changes.
   - PR text should be updated when the body omits material scope, overstates the change, references stale validation, or no longer matches the latest commits.

6. Fix when authorized.
   - Patch docs/plans with the smallest accurate update.
   - Update the PR body through the host or CLI, preserving repo conventions.
   - Run relevant validation for changed docs or generated artifacts.
   - If docs are generated, update the source and regenerate instead of editing generated output by hand.

## Output

For a check-only pass, report:

1. `Status: current | needs-update | blocked`
2. PR description findings, if any.
3. Docs/plans findings, if any.
4. Files or PR text that should change.
5. Evidence checked and any deferred areas.

For a fix pass, report:

1. `Status: updated | blocked`
2. PR description changes made.
3. Docs/plans files changed.
4. Validation commands and results.
5. Remaining risks or follow-ups.
