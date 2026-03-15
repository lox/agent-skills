# Slack CLI Patterns

Use this reference when building a Go CLI that should follow the same shape as `/Users/lachlan/Develop/lox/slack-cli`.

## Entry Point

- `/Users/lachlan/Develop/lox/slack-cli/main.go` keeps startup thin:
  - create the root `cmd.CLI`
  - parse with `kong.Parse(...)`
  - load config once
  - run the selected command with shared context
  - let Kong handle fatal exits

## Command Tree

- `/Users/lachlan/Develop/lox/slack-cli/cmd/root.go` keeps:
  - the shared runtime `Context`
  - global flags such as `--workspace`
  - the root `CLI` struct with subcommands as fields
  - a leaf `VersionCmd` with `Run(*Context) error`
- `/Users/lachlan/Develop/lox/slack-cli/cmd/channel.go` shows one cohesive command family per file: parent command plus leaf commands with Kong tags and direct orchestration.
- `/Users/lachlan/Develop/lox/slack-cli/cmd/view.go` shows how to keep parsing and rendering helpers near the command when they are only used there.

## Package Boundaries

- `cmd/` handles flags, arguments, and orchestration.
- `internal/config/config.go` owns config path selection, load or save concerns, normalization, and migration helpers.
- `internal/slack/` owns API client behavior, URL parsing, and domain-specific types.
- `internal/output/markdown.go` shows a dedicated rendering package for richer terminal output instead of bloating command files.

## Output Style

- Normal command results print with `fmt.Printf` or `fmt.Println`.
- Rendering concerns move into `internal/output` once formatting becomes reusable or non-trivial.
- Warnings in existing code still use the standard library `log`, but new CLI code should standardize on `github.com/charmbracelet/log` instead.

## Testing Pattern

- `/Users/lachlan/Develop/lox/slack-cli/cmd/root_test.go` tests command context behavior directly instead of spawning a process.
- `/Users/lachlan/Develop/lox/slack-cli/cmd/workspace_hint_test.go` and `/Users/lachlan/Develop/lox/slack-cli/internal/slack/url_test.go` show focused behavior tests around parsing and user guidance.
- Prefer narrow package tests first, then broader `go test ./...` coverage.

## Design Cues Worth Reusing

- Keep `main.go` thin and keep command wiring in `cmd/`.
- Keep command families cohesive by file.
- Keep shared runtime dependencies in a context object instead of globals.
- Keep normal output deterministic and readable for terminals and scripts.
