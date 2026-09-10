---
name: work-walkthrough
description: Produces a concrete end-of-work walkthrough grounded in observed behavior and validation. Use when explicitly asked for a demo, walkthrough, substantial handoff, implementation showcase, UX or CLI examples, impact, limitations, or next steps.
---

# Work walkthrough

Create a clear handoff that explains the work from the user's point of view.

## Gather evidence

- Re-read the user's request, the plan or issue when present, the final diff, validation output, commits, and PR state when a PR was in scope.
- Verify the current branch and dirty state so the walkthrough does not claim unrelated work.
- Prefer concrete file paths, commands, URLs, screenshots, and observed behavior over broad summaries.
- Do not invent impact, validation, UX behavior, or next steps. If something was not verified, say so directly.

## Demo the change

- For CLI changes, include copyable commands with realistic arguments and note the expected result. Run harmless examples when practical; use dry-run, help, fixture, or read-only commands when real operations would mutate user data.
- Distinguish a code walkthrough, automated validation, recorded artifact, and live demo. Do not imply one was performed when only another was available.
- For web UI changes in a remote agent environment, use the repository's declared services or the host's supervised service mechanism. Expose the listening service with the host's URL-forwarding, tunnel, or portal capability and share that public URL, never a loopback URL.
- On a persistent workstation or runner, follow its existing service management. Do not assume local state, credentials, or ports also exist in an isolated remote environment.
- When browser automation is available, open the accessible page and verify the changed UI is visible. If URL forwarding or verification fails, report the exact limitation rather than claiming a live showcase.
- For API or service changes, include representative `curl`, config, payload, or log examples when they are safe and useful.
- If no local showcase is practical, explain the concrete blocker and provide the closest useful command, test, screenshot path, or manual verification route.
- Do not leave unnecessary servers running unless the user needs the URL to keep testing. If a supervised service remains running, name it and explain how to stop it.

## Output

Write it per `writing-plainly`, in this order unless the user asked for a different format. Cover each point that applies; merge or drop the rest. Do not add a heading for a point that has nothing to say.

1. The problem, and why it mattered. Start here, not with a list of files.
2. What changed: the behavior, files, commands, UI, schema, or workflow, and what users or operators can now do that they could not before.
3. How to try it: commands, a public demo URL, API examples, an artifact, or validation commands, each with the expected result. Include examples for behavior changes; skip them for invisible cleanup.
4. User-visible changes to output, flags, errors, or screens, when there are any.
5. What was hard or surprising: design changes, bugs found, validation surprises, tradeoffs.
6. Validation run, and whether each check passed, failed, or was skipped and why.
7. Next steps, only when there is a specific follow-up worth doing. Name it; "continue improving this" is not a next step.

The result is a practical walkthrough, not a changelog dump. A small change may need three short paragraphs.
