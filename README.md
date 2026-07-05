# agent-skills

Reusable Amp/Codex skills managed with `skillyard`.

## Included Skills

- `adversarial-code-reviewing`: Guidance for skeptical, high-signal code reviews that look for material ship blockers and subtle production risks.
- `addressing-pr-reviews`: Workflow for triaging and replying to GitHub PR review comments.
- `auto-review`: Iterative workflow for reviewing a current PR, fixing grounded findings, validating, and re-reviewing until it is ready or blocked.
- `babysitting-prs`: Workflow for getting GitHub pull requests through reviews, Codex feedback, Buildkite failures, rebases, merge queues, and final merge.
- `birdclaw`: Command-line workflows for reading X posts and syncing, reading, and troubleshooting local Twitter/X memory in Birdclaw.
- `check-docs-updated`: Checks repository docs, plans, examples, and runbooks against the actual diff.
- `check-pr-description`: Checks PR titles and descriptions against the actual diff and repository PR conventions.
- `ask-fable`: Uses Fable through the Amp CLI for an independent read-only review of plans, diffs, architecture choices, or testing strategy.
- `consulting-librarian`: Guidance for emulating Amp's Librarian workflow inside non-Amp agents to understand repositories outside the current workspace. Installed only for non-Amp agents because Amp already includes Librarian guidance.
- `drafting-plans`: Guidance for drafting durable engineering plan docs with clear scope, sequencing, validation, decisions, and open questions.
- `executing-plans`: Workflow for executing plan slices locally on a branch through plan review, validation, auto-review cleanup, per-slice commits, and a final walkthrough, with optional PR publication and babysitting when requested.
- `frontend-design`: Guidance for creating distinctive, production-grade frontend interfaces with a strong visual point of view.
- `general-code-reviewing`: Orchestrates broad code reviews by running separate ship-risk and maintainability passes, then synthesizing the results.
- `go-cli-writing`: Guidance for building and reviewing Go CLIs with Kong, charmbracelet/log, and clean command layout.
- `go-writing`: Guidelines for writing, reviewing, and modernising Go code with version-gated guidance, linting, and toolchain management.
- `handling-codex-reviews`: Codex-specific GitHub PR review loop for waiting on reviews, fixing feedback, resolving threads, and requiring Codex's main-thread thumbs-up.
- `high-performance-zig`: Guidance for writing and reviewing fast Zig systems code with measurement, cache-aware layout, comptime specialization, SIMD fast paths, and allocator discipline.
- `humanizing-text`: Guidance for rewriting AI-sounding text to feel more natural and human.
- `improve-codebase-architecture`: Guidance for finding codebase architecture deepening opportunities.
- `land-pr`: Full code-to-merged-PR workflow that auto-reviews, opens or updates a PR, babysits it through CI and reviews, then merges it.
- `linear`: Command-line workflows for searching and managing Linear issues.
- `notion`: Command-line workflows for searching and managing Notion pages, databases, and comments.
- `reading-x-posts`: Read x.com and twitter.com posts through xurl, with Birdclaw as the local cache and research fallback.
- `speak-like-lachlan`: Guidance for drafting or rewriting text in Lachlan's Slack voice and operating style.
- `slack`: Command-line workflows for reading Slack messages, threads, channels, and users.
- `thermo-nuclear-code-quality-review`: Extremely strict maintainability review for abstraction quality, file sprawl, and spaghetti-condition growth.
- `work-walkthrough`: Final handoff workflow for explaining the problem, changes, impact, UX, examples or local demo, validation, surprises, and next steps.

## Attribution

The `improve-codebase-architecture` skill is adapted from Matt Pocock's [`mattpocock/skills`](https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture) repository. These materials are licensed under MIT. Copyright (c) 2026 Matt Pocock.

The `thermo-nuclear-code-quality-review` skill is adapted from Cursor's [`cursor/plugins`](https://github.com/cursor/plugins/blob/3347cbab5b54136f6fba0994c3a01a56f7fb7fca/cursor-team-kit/skills/thermo-nuclear-code-quality-review/SKILL.md) repository at commit `3347cbab5b54136f6fba0994c3a01a56f7fb7fca`. Cursor Team Kit is licensed under MIT; the upstream permission notice is included in `thermo-nuclear-code-quality-review/LICENSE`.

## Structure

Each skill lives in its own directory and is centred on a `SKILL.md` file.
Some skills also include helper scripts under `scripts/`.
Some skills also include agent-specific prompt metadata under `agents/`.

## Installation

Use `skillyard` to subscribe Codex and Amp to the published repo:

```bash
skillyard setup
skillyard subscribe github:lox/agent-skills --include '*' --target codex --force
skillyard subscribe github:lox/agent-skills --include '*' --exclude consulting-librarian --target amp --force
```

`mise run install` runs the two `subscribe` commands. The `--force` flag is useful when migrating old repo-owned symlinks; omit it if you want `skillyard` to stop instead of replacing unmanaged links.

`consulting-librarian` is Codex-only because Amp already includes Librarian guidance.

After the subscription exists, use `skillyard sync github:lox/agent-skills` to reconcile installed links with the current locked source state.

## Linting

This repo uses `mise` to install and run `skills-lint`.

```bash
mise install
mise run lint
```

Linting is configured in `.skills-lint.config.json` and currently scans `./*/SKILL.md`.
