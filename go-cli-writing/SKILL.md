---
name: go-cli-writing
description: Builds and reviews Go command-line applications with idiomatic package layout, command parsing, logging, config loading, scriptable output, and behavior-first tests. Use when creating or refactoring `main.go`, command trees, flags, subcommands, help text, config handling, or CLI UX in Go.
---

# Go CLI Writing

Keep Go CLIs predictable, scriptable, and easy to extend. Favor a thin `main`, a `cmd` package of Kong command structs, internal packages for config and API logic, and direct command results on stdout.

## Start With Local Context

- Read `go.mod`, `main.go`, the `cmd/` package, config loading, adjacent tests, and `mise.toml`, `.mise.toml`, or `.tool-versions` when present before changing structure.
- Follow the repository's parser, logger, version manager, and lint setup when present. For a small new command, consider the standard library before adding dependencies.
- For a new multi-command CLI with no established stack, prefer `github.com/alecthomas/kong`, `github.com/charmbracelet/log`, `mise`, and `golangci-lint`; these are intentional defaults, not reasons to replace a working repository convention.
- Open [references/slack-cli-patterns.md](references/slack-cli-patterns.md) when a concrete lox CLI example would help.
- Keep CLI-specific structure here. Use broader Go package guidance only for non-CLI design questions.

## Work In This Order

1. Inspect the command tree, global flags, config flow, and current stdout or stderr behavior.
2. Decide whether the change belongs in `main.go`, `cmd/`, or an `internal/` package before adding code.
3. Write the smallest failing test for the behavior change.
4. Implement the narrowest command or helper change that makes the test pass.
5. Run focused verification, then the broader CLI checks.

## Shape The Packages

- Keep `main.go` thin. It should wire version data, call `kong.Parse`, load config, build runtime context, run the selected command, and handle the final fatal path.
- Keep the root CLI type and shared runtime `Context` in `cmd/root.go`.
- Model each command family as a small struct in `cmd/`, with `Run(*Context) error` on the leaf command type.
- Keep a type and its methods in the same file. Do not split methods with the same receiver across files just to shorten files.
- Split command files by cohesive command family, not arbitrary line counts.
- Put config, API clients, parsers, renderers, and persistence under `internal/`. Keep `cmd/` focused on argument handling and orchestration.

## Use Kong Deliberately When Chosen

- Use `github.com/alecthomas/kong` for new multi-command Go CLIs when the repository has not selected another parser.
- Define the CLI as nested structs with explicit Kong tags such as `cmd:""`, `arg:""`, `help`, `default`, and `short`.
- Keep flag names, defaults, and help text stable and explicit. Optimize for discoverability in `--help`.
- Pass parser options in `main.go`, typically `kong.Name`, `kong.Description`, `kong.UsageOnError()`, and `kong.Vars` for version wiring when needed.
- Prefer command methods that return errors over commands that print errors and continue.

## Logging And Output

- When Charm is the chosen or existing logger, use `github.com/charmbracelet/log` for diagnostics, warnings, retries, and operational logging. Otherwise follow the repository's logger; do not add a second logging stack.
- Keep normal command results on stdout with `fmt` or a dedicated output package so the CLI remains script-friendly.
- Return errors with context instead of logging and returning the same error.
- Do not use `panic` for normal user-facing failures.
- Do not discard errors with `_` unless the ignore is deliberate, local, and obvious to the reader.
- Reserve stderr or logger output for warnings, degraded behavior, interactive guidance, or debug and verbose modes.

## Config And Runtime Context

- Load config once near startup and pass it through a shared runtime context.
- Keep config schema, path resolution, and migration logic in `internal/config`.
- Prefer `os.UserConfigDir()` or repository-standard config locations over ad hoc paths.
- Keep environment-variable overrides explicit and close to config loading.

## Test The CLI Behavior

- Start with a failing test for parsing, config resolution, or command behavior before changing implementation.
- Prefer narrow tests on command helpers, config helpers, and parsing utilities before reaching for subprocess end-to-end tests.
- Use table-driven tests for flags, positional args, resolver logic, and output edge cases.
- Add one smoke check for help or version paths when changing root command wiring.

## Verify Before Finishing

- Run the narrowest useful package tests while iterating.
- Finish with the repository's normal formatter, tests, vet/lint checks, and a CLI smoke check such as `go run . --help` or its build script. When no workflow exists, use `gofmt -w`, `go test ./...`, and `go vet ./...`; run `golangci-lint` when configured.
- If dependencies change, keep `go.mod` and `go.sum` tidy and call out the new package choice explicitly.
- If a new or modernized repository lacks linting, recommend `golangci-lint` without introducing it as part of an unrelated command change.

## Output Expectations

- Explain any non-obvious command-tree or package-boundary choice in one or two sentences.
- Call out when normal user-facing output intentionally stays separate from logs.
- Prefer examples that match the existing CLI layout instead of inventing a new pattern.
