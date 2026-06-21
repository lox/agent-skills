---
name: work-walkthrough
description: Produce a concrete end-of-work walkthrough after implementation, plan execution, PR preparation, or a completed local branch slice. Use when the user asks for a walkthrough, demo, handoff, summary of completed work, what changed and why, UX or CLI examples, local web showcase, impact, unexpected difficulty, or next suggested steps; also use as the final handoff step from executing-plans.
---

# Work Walkthrough

Create a clear handoff that explains the work from the user's point of view.

## Gather Evidence

- Re-read the user's request, the plan or issue when present, the final diff, validation output, commits, and PR state when a PR was in scope.
- Verify the current branch and dirty state so the walkthrough does not claim unrelated work.
- Prefer concrete file paths, commands, URLs, screenshots, and observed behavior over broad summaries.
- Do not invent impact, validation, UX behavior, or next steps. If something was not verified, say so directly.

## Demo The Change

- For CLI changes, include copyable commands with realistic arguments and note the expected result. Run harmless examples when practical; use dry-run, help, fixture, or read-only commands when real operations would mutate user data.
- For web UI changes, start the existing local dev server when the repo provides one and it is safe to run. Use the repo's normal command, choose an available port if needed, and provide the local URL. When browser automation is available, open the page and verify the changed UI is visible.
- For API or service changes, include representative `curl`, config, payload, or log examples when they are safe and useful.
- If no local showcase is practical, explain the concrete blocker and provide the closest useful command, test, screenshot path, or manual verification route.
- Do not leave unnecessary servers running unless the user needs the URL to keep testing. If a server remains running, say which command/session is running and how to stop it.

## Output Shape

Use this structure unless the user requested a different format:

1. Problem: what the work was trying to solve and why it mattered.
2. What changed: the concrete behavior, files, commands, UI, schema, or workflow changes.
3. Impact: what users, developers, or operators can now do, and what risks were reduced.
4. How to try it: CLI commands, local URL, API examples, or validation commands with expected outcomes.
5. UX changes: user-visible behavior, CLI output, flags, errors, screens, or interaction changes. Say "None" only when that is accurate.
6. Hard or unexpected: friction, design changes, bugs found, validation surprises, or tradeoffs discovered.
7. Validation: checks run and whether they passed, failed, or were skipped with reason.
8. Next suggested steps: the smallest concrete follow-ups in priority order.

## Style

- Keep it concise but useful. The goal is a practical walkthrough, not a changelog dump.
- Start with the problem or motivation, not a list of files.
- Include examples for behavior changes; do not include examples for invisible cleanup unless they clarify reviewer or operator impact.
- Make next steps actionable. Avoid vague prompts like "continue improving this" unless there is no better concrete next action.
