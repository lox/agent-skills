# agent-skills

Reusable Amp/agent skills that can be copied into other environments.

## Included Skills

- `addressing-pr-reviews`: Workflow for triaging and replying to GitHub PR review comments.
- `autofixing-codex-reviews`: Automated loop for handling Codex PR feedback, fixing code, and posting replies.
- `go-cli-writing`: Guidance for building and reviewing Go CLIs with Kong, charmbracelet/log, and clean command layout.
- `go-writing`: Guidelines for writing, reviewing, and modernising Go code with version-gated guidance, linting, and toolchain management.
- `humanizing-text`: Guidance for rewriting AI-sounding text to feel more natural and human.
- `linear`: Command-line workflows for searching and managing Linear issues.
- `notion`: Command-line workflows for searching and managing Notion pages, databases, and comments.
- `slack`: Command-line workflows for reading Slack messages, threads, channels, and users.

## Structure

Each skill lives in its own directory and is centred on a `SKILL.md` file.
Some skills also include helper scripts under `scripts/`.

## Linting

This repo uses `mise` to install and run `skills-lint`.

```bash
mise install
mise run lint
```

Linting is configured in `.skills-lint.config.json` and currently scans `./*/SKILL.md`.
