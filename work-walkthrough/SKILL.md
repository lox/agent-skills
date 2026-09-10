---
name: work-walkthrough
description: Produces a concrete end-of-work walkthrough grounded in observed behavior and validation. Use when explicitly asked for a demo, walkthrough, substantial handoff, implementation showcase, UX or CLI examples, impact, limitations, or next steps.
---

# Work walkthrough

Explain finished work from the user's side: what they can do now, how to try it, and what to trust.

## Gather evidence

Re-read the request, the plan or issue, the final diff, validation output, commits, and PR state. Check the branch and dirty state so the walkthrough does not claim unrelated work. Prefer file paths, commands, URLs, screenshots, and observed behavior over summary. Say plainly what was not verified. Do not describe a demo, validation, or artifact you did not produce.

## Demo the change

For a CLI change, give copyable commands with realistic arguments and the expected result. Run harmless ones when practical; use dry-run, help, fixture, or read-only commands where a real run would change user data. For an API or service change, give a `curl`, config, payload, or log example when it is safe.

For a web UI change in a remote agent environment, start the repository's declared services or the host's supervised service, expose it through the host's portal or tunnel, and share that public URL, never a loopback address. On a workstation or runner, use its existing service management, and do not assume local credentials or ports exist remotely. When browser automation is available, open the page and confirm the changed UI is visible. If forwarding or verification fails, name the exact failure and give the closest useful command, test, or screenshot instead.

Do not leave servers running unless the user needs the URL. If one stays up, name it and say how to stop it.

## Output

Write per `writing-plainly`, in this order unless the user asked for another format. Cover what applies and drop the rest. No heading for a point with nothing under it.

1. The problem and why it mattered. Start here, not with files.
2. What changed and what users or operators can now do that they could not before, including any visible change to output, flags, errors, or screens.
3. How to try it: commands, a public demo URL, API examples, an artifact, or validation commands, each with the expected result. Skip for invisible cleanup.
4. What was hard or surprising: design changes, bugs found, tradeoffs.
5. Validation run, and whether each check passed, failed, or was skipped and why.
6. A next step, only when there is a specific one worth doing. "Continue improving this" is not one.

A small change may need three short paragraphs.
