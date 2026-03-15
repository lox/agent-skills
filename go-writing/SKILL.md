---
name: go-writing
description: Write, review, and refactor Go code with idiomatic package design, naming, error handling, concurrency, performance, testing, linting, and toolchain management. Use when Codex is implementing or reviewing `.go` changes, adding Go tests or benchmarks, setting up lint or version tooling, reshaping package APIs, choosing between Go patterns, or applying current version-gated Go guidance while respecting the repository's actual toolchain and conventions.
---

# Go Writing

Keep Go code boring, explicit, version-aware, and easy to verify. Start from repository conventions, then use official Go guidance and version-specific modernization references to break ties or fill gaps.

## Start With Local Context

- Read `go.mod`, `go.work`, `mise.toml`, `.mise.toml`, or `.tool-versions` when present, plus the changed package, adjacent tests, and build or CI scripts before proposing structure.
- Treat the module or workspace `go` directive as the minimum language and compatibility target.
- Check `toolchain` directives, `mise` config, CI or container toolchains, and deployment/runtime constraints before suggesting tool invocations or standard-library APIs that may depend on the actual Go toolchain in use.
- Follow repository conventions before generic advice.
- Prefer small, local changes. Add abstractions only after the concrete shape is clear.
- Prefer `mise` for pinning Go and related tool versions in new or modernized repositories unless the repository already standardized on another version manager.
- Open [references/official-go-guidance.md](references/official-go-guidance.md) when the repository is ambiguous or the design tradeoff is language-level rather than project-specific.
- Open [references/go-1.26-modernization.md](references/go-1.26-modernization.md) when the user asks for the latest Go patterns, when the repo already targets Go 1.26+, or when planning a toolchain upgrade.
- Open [../go-cli-writing/SKILL.md](../go-cli-writing/SKILL.md) when the work is primarily about CLI structure, subcommands, flag UX, or command output.

## Work In This Order

1. Inspect the package boundary, dependencies, tests, and module version.
2. Decide whether the problem needs a new type, function, interface, goroutine, or dependency at all.
3. Write the smallest clear implementation that matches the surrounding package.
4. Add or update tests and benchmarks before optimizing.
5. Run the narrowest useful verification loop, then the repo's broader checks.

## Shape The API

- Choose package names that are short, lower-case, and non-stuttering.
- Keep exported APIs small and documented. Add doc comments for exported identifiers, and add a package comment when creating a new package.
- Start with concrete types and functions. Introduce an interface only at the consuming boundary or when multiple implementations already exist.
- Accept small interfaces when they model the exact behavior needed. Return concrete types unless hiding the concrete type is a deliberate API choice.
- Make the zero value useful when practical. Add constructors only for invariants, required dependencies, or resource ownership.
- Keep data ownership obvious. Pass small values by value; use pointers for mutation, large structs, or shared identity.
- Use pointer receivers for mutation, large structs, or structs containing locks. Use value receivers for small immutable values.
- Keep receiver style consistent on a type. Do not mix pointer and value receivers without a deliberate method-set reason.
- Keep `context.Context` as the first parameter on request-scoped work, blocking operations, and cancellable I/O. Do not store it in a struct.
- Avoid package names such as `util`, `common`, `misc`, `types`, and `api` unless the repository already normalized them.

## Organize Files For Cohesion

- Optimize file layout for cohesion and reader navigation, not an arbitrary line-count limit.
- Split long files only when the new file creates a real boundary such as a distinct type family, protocol, platform, generated code path, or test fixture area.
- Keep a type and its methods close together. Do not split methods with the same receiver across files just to shorten files unless there is a strong boundary such as build tags or generated code.

## Write The Implementation

- Prefer straight-line control flow with early returns over deep nesting.
- Return errors instead of logging or exiting inside library code.
- Do not use `panic` for normal error handling.
- Use `errors.New` for fixed values and `fmt.Errorf("...: %w", err)` when preserving a cause matters.
- Use `%v` instead of `%w` at API or trust boundaries when callers should not depend on the underlying implementation detail.
- Handle each error once. Either return it with context or log it while degrading gracefully.
- Do not discard errors with `_` unless the ignore is deliberate, local, and obvious to the reader.
- Keep error strings lower-case and without trailing punctuation.
- Keep wrapping context short. Prefer `open config: %w` over repeated `failed to ...` chains.
- Use `errors.Is`, `errors.As`, and `errors.Join` when the caller needs machine-readable error behavior.
- Keep helpers small, cohesive, and near their callers unless reuse is already proven.
- Avoid speculative generalization, reflection-heavy code, and hidden magic.
- Avoid new dependencies for trivial helpers when the standard library already covers the job.
- Prefer standard-library helpers such as `cmp`, `maps`, and `slices` before adding custom glue code.

## Shape Data Carefully

- Prefer nil slices over empty slices unless an external contract requires `[]` instead of `null`.
- Preallocate slices when the final size is known or tightly bounded.
- Copy slices or maps at ownership boundaries when retaining mutable caller-provided data.
- Use field names in struct literals outside tightly local tests.
- Avoid embedding locks or other implementation details in exported structs.

## Use Concurrency Deliberately

- Add goroutines only when they improve latency, throughput, or responsiveness in a clear way.
- Thread context cancellation through concurrent work.
- Use `errgroup` from `golang.org/x/sync/errgroup` for sibling tasks that fail or cancel together when the repository already uses `x/sync` or the dependency is justified. Otherwise use a clear standard-library coordination pattern. Use `sync.WaitGroup` only for simple coordination.
- Prefer synchronous function signatures; let callers opt into concurrency.
- Document how each goroutine exits. Treat goroutine lifetime as part of the design.
- Let the sending side close channels and keep channel ownership explicit.
- Default channel sizes to `0` or `1`. Larger buffers need a reason tied to load, backpressure, or batching.
- Protect shared mutable state or remove the sharing.
- Use typed atomics from `sync/atomic` when atomics are truly the right tool.

## Test Behavior First

- Start with a failing test when changing behavior.
- Prefer table-driven tests for input or state matrices, and use subtests to name cases.
- Use `t.Helper()` in helpers and `t.Parallel()` only when the test and its fixtures are concurrency-safe.
- Test observable behavior and error semantics, not private implementation details.
- Prefer standard-library assertions unless the repository already standardizes on another test helper library.
- Check wrapped errors with `errors.Is` and `errors.As`.
- Add fuzz tests for parsers, decoders, and input-validation code when the risk justifies it.
- Add benchmarks before claiming a performance win. Use `pprof` only after measuring a real bottleneck.

## Verify Before Finishing

- Run the narrowest useful package test loop while iterating, then run the repository's broader verification path.
- Use repository tooling if it exists. Otherwise default to `gofmt -w`, `go test ./...`, `go vet ./...`, `golangci-lint run`, `go test -race ./...` for concurrency changes, and `go mod tidy` when dependencies change.
- After a Go toolchain upgrade or modernization pass, consider `go fix ./...` before manual cleanup.
- Regenerate generated files instead of hand-editing them unless the repository explicitly treats them as maintained sources.
- Keep imports and module metadata consistent with the repository workflow.
- If the repository lacks linting, recommend adding `golangci-lint` instead of treating lint as optional.

## Output Expectations

- Explain any non-obvious Go tradeoff in one or two sentences.
- Call out repository-specific deviations from generic Go advice when they matter.
- State when an idea needs a higher module or toolchain version than the repository currently declares.
- Prefer examples that match the package already being edited instead of inventing a new style.
