---
name: work-walkthrough
description: Produces a concrete end-of-work walkthrough grounded in observed behavior and validation. Use when asked for a demo, handoff, implementation summary, UX or CLI examples, web showcase, impact, limitations, or next steps; also use after executing a plan.
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
- Distinguish a code walkthrough, automated validation, recorded artifact, and live demo. Do not imply one was performed when only another was available.
- For web UI changes in a remote agent environment, use the repository's declared services or the host's supervised service mechanism. Expose the listening service with the host's URL-forwarding, tunnel, or portal capability and share that public URL, never a loopback URL.
- On a persistent workstation or runner, follow its existing service management. Do not assume local state, credentials, or ports also exist in an isolated remote environment.
- When browser automation is available, open the accessible page and verify the changed UI is visible. If URL forwarding or verification fails, report the exact limitation rather than claiming a live showcase.
- For API or service changes, include representative `curl`, config, payload, or log examples when they are safe and useful.
- If no local showcase is practical, explain the concrete blocker and provide the closest useful command, test, screenshot path, or manual verification route.
- Do not leave unnecessary servers running unless the user needs the URL to keep testing. If a supervised service remains running, name it and explain how to stop it.

## Output Shape

Use this structure unless the user requested a different format:

1. Problem: what the work was trying to solve and why it mattered.
2. What changed: the concrete behavior, files, commands, UI, schema, or workflow changes.
3. Impact: what users, developers, or operators can now do, and what risks were reduced.
4. How to try it: CLI commands, public demo URL, API examples, artifact, or validation commands with expected outcomes.
5. UX changes: user-visible behavior, CLI output, flags, errors, screens, or interaction changes. Say "None" only when that is accurate.
6. Hard or unexpected: friction, design changes, bugs found, validation surprises, or tradeoffs discovered.
7. Validation: checks run and whether they passed, failed, or were skipped with reason.
8. Next suggested steps: the smallest concrete follow-ups in priority order.

## Style

- Keep it concise but useful. The goal is a practical walkthrough, not a changelog dump.
- Start with the problem or motivation, not a list of files.
- Include examples for behavior changes; do not include examples for invisible cleanup unless they clarify reviewer or operator impact.
- Make next steps actionable. Avoid vague prompts like "continue improving this" unless there is no better concrete next action.
