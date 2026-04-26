# agent-skills

Reusable Amp/agent skills that can be copied into other environments.

## Included Skills

- `adversarial-code-reviewing`: Guidance for skeptical, high-signal code reviews that look for material ship blockers and subtle production risks.
- `addressing-pr-reviews`: Workflow for triaging and replying to GitHub PR review comments.
- `autofixing-codex-reviews`: Automated loop for handling Codex PR feedback, fixing code, and posting replies.
- `consulting-librarian`: Guidance for emulating Amp's Librarian workflow inside non-Amp agents to understand repositories outside the current workspace. Installed only for non-Amp agents because Amp already includes Librarian guidance.
- `go-cli-writing`: Guidance for building and reviewing Go CLIs with Kong, charmbracelet/log, and clean command layout.
- `go-writing`: Guidelines for writing, reviewing, and modernising Go code with version-gated guidance, linting, and toolchain management.
- `humanizing-text`: Guidance for rewriting AI-sounding text to feel more natural and human.
- `linear`: Command-line workflows for searching and managing Linear issues.
- `notion`: Command-line workflows for searching and managing Notion pages, databases, and comments.
- `slack`: Command-line workflows for reading Slack messages, threads, channels, and users.

## Structure

Each skill lives in its own directory and is centred on a `SKILL.md` file.
Some skills also include helper scripts under `scripts/`.
Some skills also include agent-specific prompt metadata under `agents/`.

`mise run install` links all skills into both supported skill directories except `consulting-librarian`, which is linked only into `~/.agents/skills` so it stays out of Amp's built-in skill set.

## Linting

This repo uses `mise` to install and run `skills-lint`.

```bash
mise install
mise run lint
```

Linting is configured in `.skills-lint.config.json` and currently scans `./*/SKILL.md`.
