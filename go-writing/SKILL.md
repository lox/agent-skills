---
name: go-writing
description: Writes, reviews, and refactors Go code with idiomatic package design, error handling, concurrency, performance, tests, linting, and toolchain awareness. Use when implementing or reviewing `.go` changes, tests, benchmarks, package APIs, or version-gated Go modernization.
---

# Go writing

Write explicit, version-aware Go that follows the repository. Use official Go guidance and version-specific references when local conventions do not settle a choice.

## Start with local context

- Read `go.mod`, `go.work`, `mise.toml`, `.mise.toml`, or `.tool-versions` when present. Also read the changed package, adjacent tests, and build or CI scripts.
- Treat the module or workspace `go` directive as the minimum language and compatibility target.
- Check `toolchain` directives, `mise` config, CI or container toolchains, and runtime constraints before suggesting tool invocations or standard-library APIs tied to a Go version.
- Follow repository conventions. Prefer small, local changes, and add abstractions only after the concrete shape is clear.
- Use the existing version manager. Prefer `mise` only for a new or deliberately modernized repository with no established alternative.
- Open [references/official-go-guidance.md](references/official-go-guidance.md) when the repository is ambiguous or the tradeoff concerns the language rather than the project.
- Open [references/go-1.26-modernization.md](references/go-1.26-modernization.md) when the user asks for the latest Go patterns, the repository targets Go 1.26+, or the work plans a toolchain upgrade.
- Open [../go-cli-writing/SKILL.md](../go-cli-writing/SKILL.md) for CLI structure, subcommands, flag UX, or command output.

## Order of work

1. Inspect the package boundary, dependencies, tests, and module version.
2. Decide whether the problem needs a new type, function, interface, goroutine, or dependency.
3. Write the smallest clear implementation that fits the package.
4. Add or update tests and benchmarks when the change or performance claim deserves them.
5. Run focused checks, then the repository's broader checks.

## Shape the API

- Use short, lower-case, non-stuttering package names. Avoid `util`, `common`, `misc`, `types`, and `api` unless the repository uses them consistently.
- Keep exported APIs small. Add doc comments for exported identifiers and a package comment for a new package.
- Start with concrete types and functions. Add an interface at the consuming boundary or when multiple implementations exist.
- Accept small interfaces that name the exact behavior. Return concrete types unless hiding one is a deliberate API choice.
- Make the zero value useful when practical. Add constructors for invariants, required dependencies, or resource ownership.
- Pass small values by value. Use pointers for mutation, large structs, shared identity, or receivers on structs that contain locks.
- Use value receivers for small immutable values. Keep receiver style consistent unless method sets require a mix.
- Put `context.Context` first for request-scoped work, blocking operations, and cancellable I/O. Do not store it in a struct.

## Organize files for cohesion

Organize files by cohesive concepts, not line count. Keep a type and its methods together. Split a file only at a real boundary such as a type family, protocol, platform, generated code path, test fixtures, build tags, or generated code.

## Write the implementation

- Prefer straight-line control flow and early returns.
- Library code returns errors rather than logging, exiting, or using `panic` for normal failures.
- Use `errors.New` for fixed values and `fmt.Errorf("...: %w", err)` to preserve a cause. Use `%v` at API or trust boundaries where callers should not depend on the cause.
- Handle each error once. Return it with context or log it while degrading. Ignore an error with `_` only when that choice is deliberate, local, and obvious.
- Keep error strings lower-case without trailing punctuation. Keep context short, such as `open config: %w`, rather than repeated `failed to ...` chains.
- Use `errors.Is`, `errors.As`, and `errors.Join` when callers need machine-readable error behavior.
- Keep helpers cohesive and near callers until reuse is proven.
- Avoid speculative generalization, reflection-heavy code, hidden magic, and dependencies for helpers the standard library provides.
- Prefer standard-library helpers such as `cmp`, `maps`, and `slices` over custom glue.

## Shape data carefully

- Prefer nil slices unless an external contract requires `[]` instead of `null`.
- Preallocate slices when the final size is known or tightly bounded.
- Copy slices or maps at ownership boundaries when retaining mutable caller data.
- Name fields in struct literals outside tightly local tests.
- Do not embed locks or other implementation details in exported structs.

## Use concurrency deliberately

- Add goroutines only for a clear latency, throughput, or responsiveness gain. Prefer synchronous APIs so callers choose concurrency.
- Thread context cancellation through concurrent work and document how every goroutine exits.
- Use `errgroup` from `golang.org/x/sync/errgroup` for sibling tasks that fail or cancel together when the repository uses `x/sync` or the dependency is justified. Otherwise use clear standard-library coordination. Use `sync.WaitGroup` only for simple coordination.
- The sending side closes channels. Keep channel ownership explicit.
- Default channel sizes to `0` or `1`. Tie larger buffers to load, backpressure, or batching.
- Protect shared mutable state or remove the sharing. Use typed atomics from `sync/atomic` only when atomics fit the problem.

## Test behavior first

- Start with a failing test when the change deserves one (see `writing-tests`).
- Prefer table-driven tests for input or state matrices. Use subtests to name cases.
- Use `t.Helper()` in helpers and `t.Parallel()` only with concurrency-safe tests and fixtures.
- Test observable behavior and error semantics, not private details. Check wrapped errors with `errors.Is` and `errors.As`.
- Prefer standard-library assertions unless the repository uses another test library.
- Add fuzz tests for parsers, decoders, and input validation when the risk justifies them.
- Add benchmarks before claiming a performance win. Use `pprof` only after measuring a real bottleneck.

## Verify before finishing

- Run focused package tests while iterating, then the repository's broader checks.
- Use repository tooling. Otherwise run `gofmt -w`, `go test ./...`, and `go vet ./...`. Add `go test -race ./...` for concurrency changes and `go mod tidy` when dependencies change.
- After a toolchain upgrade or modernization pass, consider `go fix ./...` before manual cleanup.
- Regenerate generated files rather than editing them unless the repository treats them as maintained sources.
- Keep imports and module metadata consistent with the repository workflow.
- If the repository lacks linting, recommend a suitable lint path instead of adding tooling during unrelated work.

## Report the result

Explain non-obvious Go tradeoffs and deviations from generic Go advice in one or two sentences. State when an idea needs a higher module or toolchain version. Use examples that fit the package being edited.
