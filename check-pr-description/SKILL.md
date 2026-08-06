---
name: check-pr-description
description: Checks whether a pull request title and body match the actual diff, reviewer-relevant impact, and repository conventions. Use when asked to check, update, rewrite, or refresh PR metadata, or fix stale PR text after a branch changes.
---

# Check PR Description

Verify that a PR's title and body match what the branch actually changes. Keep this focused on host PR metadata; use `check-docs-updated` for repository docs, plans, examples, and runbooks.

## Operating Contract

- Treat the current PR as the target when one exists; otherwise use the branch diff and any draft PR text the user supplied.
- Use fresh PR metadata from the host: title, body, base SHA, head SHA, changed files, and comments that materially changed scope.
- Respect repository PR-description conventions from `AGENTS.md`, contribution docs, or prior PRs. For example, do not add validation sections when the repo discourages them.
- Preserve caller, platform, or connector-required output formats.
- Do not edit PR metadata unless the user asked to update, fix, prepare, or carry the PR forward. When only asked to check, report findings.
- Keep repository file changes out of this skill; if docs need edits, hand off to `check-docs-updated`.

## Workflow

1. Resolve the target.
   - Identify repo, PR number, branch, base SHA, and head SHA.
   - Fetch the current title and body from GitHub or the relevant host.
   - Inspect `git status` so PR-text work is not confused with uncommitted file changes.

2. Build the branch truth.
   - Read the diff from PR base SHA to head.
   - Inspect changed files plus enough surrounding context to understand motivation, behavior, interfaces, config, migrations, risks, and reviewer impact.
   - Include commits since the PR body was last edited when that timestamp is available.

3. Check the title.
   - Confirm it matches the current scope and repository title convention.
   - Flag titles that are too narrow after added scope, mention stale implementation details, use discouraged prefixes, or imply behavior the diff does not deliver.

4. Check the body.
   - Confirm it starts with the problem or motivation when the repo expects that.
   - Confirm it describes user or developer impact when behavior, workflow, config, APIs, or output changed.
   - Confirm examples are current when commands, config, UI text, generated output, or APIs changed.
   - Remove or flag stale claims, obsolete validation notes, outdated screenshots, wrong file names, old scope, and fixed risks presented as still open.
   - Keep implementation detail limited to what reviewers need to understand.

5. Fix when authorized.
   - Rewrite the title or body through the host or CLI, preserving repo conventions.
   - Do not add a noisy checklist or validation section if the repo does not want one.
   - Re-fetch the PR metadata after editing to verify the host state changed.

## Output

For a check-only pass, report:

1. `Status: current | needs-update | blocked`
2. Title findings, if any.
3. Body findings, if any.
4. Exact PR metadata changes recommended.
5. Evidence checked and any deferred areas.

For a fix pass, report:

1. `Status: updated | blocked`
2. Title/body changes made.
3. Any host update command or API used.
4. Remaining risks or follow-ups.
