# agent-skills

Reusable Amp/Codex skills that can be copied into other environments.

## Included Skills

- `adversarial-code-reviewing`: Guidance for skeptical, high-signal code reviews that look for material ship blockers and subtle production risks.
- `addressing-pr-reviews`: Workflow for triaging and replying to GitHub PR review comments.
- `autofixing-codex-reviews`: Automated loop for handling Codex PR feedback, fixing code, and posting replies.
- `consulting-librarian`: Guidance for emulating Amp's Librarian workflow inside non-Amp agents to understand repositories outside the current workspace. Installed only for non-Amp agents because Amp already includes Librarian guidance.
- `drafting-plans`: Guidance for drafting durable engineering plan docs with clear scope, sequencing, validation, decisions, and open questions.
- `executing-plans`: Workflow for implementing one plan slice through validation, adversarial review, cleanup, PR creation, Codex review, and passing CI.
- `frontend-design`: Guidance for creating distinctive, production-grade frontend interfaces with a strong visual point of view.
- `go-cli-writing`: Guidance for building and reviewing Go CLIs with Kong, charmbracelet/log, and clean command layout.
- `go-writing`: Guidelines for writing, reviewing, and modernising Go code with version-gated guidance, linting, and toolchain management.
- `humanizing-text`: Guidance for rewriting AI-sounding text to feel more natural and human.
- `improve-codebase-architecture`: Guidance for finding codebase architecture deepening opportunities.
- `linear`: Command-line workflows for searching and managing Linear issues.
- `notion`: Command-line workflows for searching and managing Notion pages, databases, and comments.
- `slack`: Command-line workflows for reading Slack messages, threads, channels, and users.

## Attribution

The `improve-codebase-architecture` skill is adapted from Matt Pocock's [`mattpocock/skills`](https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture) repository. These materials are licensed under MIT. Copyright (c) 2026 Matt Pocock.

## Structure

Each skill lives in its own directory and is centred on a `SKILL.md` file.
Some skills also include helper scripts under `scripts/`.
Some skills also include agent-specific prompt metadata under `agents/`.

`mise run install` links shared skills into:

- `~/.codex/skills` for the Codex macOS app and modern Codex CLI.
- `~/.config/agents/skills` for Amp.

`consulting-librarian` is Codex-only and is linked only into `~/.codex/skills`, because Amp already includes Librarian guidance. The installer also removes old repo-owned symlinks from `~/.agents/skills`; Amp can discover that legacy path from projects under the home directory, so Codex-only skills must not live there.

If the `codex` on `PATH` does not support `codex app`, update `PATH` to a newer Codex CLI before launching the macOS app.

When a destination already contains a real directory instead of a symlink, the installer moves it to a sibling `skill-backups` directory before linking the repo copy. Backups are kept outside the scanned `skills` directories so agents do not load duplicate skills.

## Linting

This repo uses `mise` to install and run `skills-lint`.

```bash
mise install
mise run lint
```

Linting is configured in `.skills-lint.config.json` and currently scans `./*/SKILL.md`.
