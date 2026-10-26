---
name: work-walkthrough
description: Produces a concrete end-of-work walkthrough grounded in observed behavior and validation. Use when explicitly asked for a demo, walkthrough, substantial handoff, implementation showcase, UX or CLI examples, impact, limitations, or next steps.
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

Use the smallest useful subset of the following unless the user requested a different format. Omit unsupported or empty sections rather than filling the template:

1. Problem: what the work was trying to solve and why it mattered.
2. What changed: the concrete behavior, files, commands, UI, schema, or workflow changes.
3. Impact: observed or directly supported changes in what users, developers, or operators can do, or risks actually reduced.
4. How to try it: CLI commands, public demo URL, API examples, artifact, or validation commands with expected outcomes.
5. UX changes: include only when user-visible behavior, CLI output, flags, errors, screens, or interactions changed.
6. Hard or unexpected: include only when the work surfaced real friction, design changes, bugs, validation surprises, or tradeoffs.
7. Validation: checks run and whether they passed, failed, or were skipped with reason.
8. Next suggested steps: include only concrete unfinished work or follow-ups supported by scope, validation, or the user's request; omit when none remain.

## Style

- Keep it concise but useful. The goal is a practical walkthrough, not a changelog dump.
- Start with the problem or motivation, not a list of files.
- Include examples for behavior changes; do not include examples for invisible cleanup unless they clarify reviewer or operator impact.
- When next steps are included, make them actionable. Avoid vague prompts like "continue improving this" unless there is no better concrete next action.
