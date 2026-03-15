# Go 1.26 Modernization

Use this reference when the user asks for the latest Go guidance or when the module already targets Go 1.26+.

Version status verified on 2026-03-15:

- Go `1.26.0` was released on 2026-02-10.
- Go `1.26.1` was released on 2026-03-05 and is the latest stable Go 1.26 release.

Primary sources:

- [Go 1.26 Release Notes](https://go.dev/doc/go1.26)
- [Go 1.26 is released](https://go.dev/blog/go1.26)
- [Release History](https://go.dev/doc/devel/release)
- [Using go fix to modernize Go code](https://go.dev/blog/gofix)

## Version Gating

- Do not assume the repository can use Go 1.26 features just because the local toolchain is newer.
- Check the module or workspace `go` directive before using 1.26-only syntax or other language-semantic changes.
- Check `toolchain` directives, CI images, and deployment/runtime toolchains before depending on newer standard-library APIs or `go` command behavior.
- If a new module must rely on Go 1.26 features, set the version intentionally after `go mod init`. Go 1.26 defaults new modules to `go 1.25.0`.

## Language Changes Worth Using

- Use `new(expr)` when it makes pointer-to-value construction clearer, especially for optional pointer fields in JSON, protobuf, or config structs.
- Do not force `new(expr)` everywhere. Existing `&value` code can remain clearer for named locals.
- Self-referential generic constraints are now allowed. Use them only for genuinely type-safe generic APIs; avoid introducing them into ordinary business code without a clear payoff.

## Tooling Changes

- Run `go fix ./...` after upgrading a codebase or before doing broad manual modernization. Go 1.26 rewrote `go fix` around the analysis framework and added modernizers.
- Treat `go fix` as a safe mechanical pass, then review the diff like any other refactor.
- Use `go doc` instead of `go tool doc`.

## Testing And Benchmarking

- Use `t.ArtifactDir()`, `b.ArtifactDir()`, or `f.ArtifactDir()` when tests need to emit files for later inspection.
- Prefer `for b.Loop() { ... }` in benchmarks for Go 1.24+ code. In Go 1.26, `B.Loop` no longer blocks inlining, so it is the preferred modern form.
- Use `testing/cryptotest.SetGlobalRandom` when deterministic crypto randomness is needed in tests.

## Upgrade Guidance

- Keep modernization separate from behavior changes when possible.
- If the repository is still on an older Go version, either:
  - stay within the current language and tooling surface, or
  - propose a dedicated toolchain bump first, then modernize in follow-up changes.
