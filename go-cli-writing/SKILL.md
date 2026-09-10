---
name: go-cli-writing
description: Builds and reviews Go command-line applications with idiomatic package layout, command parsing, logging, config loading, scriptable output, and behavior-first tests. Use when creating or refactoring `main.go`, command trees, flags, subcommands, help text, config handling, or CLI UX in Go.
---

# Go CLI writing

Keep Go CLIs predictable, scriptable, and easy to extend: a thin `main`, a `cmd` package of command structs, `internal/` packages for config and logic, and results on stdout. For anything not CLI-specific, follow `go-writing`.

## Start with local context

Read `go.mod`, `main.go`, the `cmd/` package, config loading, adjacent tests, and `mise.toml`, `.mise.toml`, or `.tool-versions` before changing structure. Follow the repository's parser, logger, version manager, and lint setup. For a small new command, consider the standard library before adding a dependency. For a new multi-command CLI with no established stack, use `github.com/alecthomas/kong`, `github.com/charmbracelet/log`, `mise`, and `golangci-lint`; these are defaults for new code, not reasons to replace a working convention. Open [references/slack-cli-patterns.md](references/slack-cli-patterns.md) for a concrete lox CLI example.

## Order of work

1. Inspect the command tree, global flags, config flow, and current stdout and stderr behaviour.
2. Decide whether the change belongs in `main.go`, `cmd/`, or `internal/` before writing code.
3. Write the smallest failing test for the behaviour, when the change deserves one (see `writing-tests`).
4. Make the narrowest command or helper change that passes it.
5. Run focused tests, then the repository's broader CLI checks.

## Packages

`main.go` wires version data, calls `kong.Parse`, loads config, builds the runtime context, runs the selected command, and handles the final fatal path. Nothing else. The root CLI type and shared runtime `Context` live in `cmd/root.go`. Each command family is a small struct in `cmd/` with `Run(*Context) error` on the leaf. Split command files by family, not by line count. Config, API clients, parsers, renderers, and persistence go under `internal/`; `cmd/` handles arguments and orchestration only.

## Kong, when chosen

Define the CLI as nested structs with explicit tags: `cmd:""`, `arg:""`, `help`, `default`, `short`. Keep flag names, defaults, and help stable and explicit, and write help for `--help` readers. Pass parser options in `main.go`, typically `kong.Name`, `kong.Description`, `kong.UsageOnError()`, and `kong.Vars` for version wiring. Commands return errors; they do not print and continue.

## Output and logging

Command results go to stdout through `fmt` or an output package so the CLI stays script-friendly. Warnings, degraded behaviour, interactive guidance, and verbose or debug output go to stderr through the logger. When Charm is the chosen or existing logger, use `github.com/charmbracelet/log`; otherwise use the repository's logger and do not add a second one. Return errors with context instead of logging and returning the same error.

## Config

Load config once near startup and pass it through the runtime context. Keep schema, path resolution, and migration in `internal/config`. Use `os.UserConfigDir()` or the repository's standard location. Keep environment-variable overrides explicit and next to config loading.

## Tests

Test parsing, config resolution, and command behaviour through narrow helpers before reaching for subprocess end-to-end tests. Use table-driven tests for flags, positional arguments, resolvers, and output edge cases. Add one smoke test for `--help` or `--version` when changing root wiring.

## Before finishing

Run the repository's formatter, tests, vet or lint, and a CLI smoke check such as `go run . --help`. If dependencies changed, tidy `go.mod` and `go.sum` and name the new package in your report. In your report, explain any non-obvious command-tree or package-boundary choice in a sentence or two, and say when user-facing output is deliberately kept separate from logs.
