# Official Go Guidance

Use this reference when repository conventions do not settle a design choice.

Primary sources:

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
- [Go Doc Comments](https://go.dev/doc/comment)
- [Package names](https://go.dev/blog/package-names)
- [Organizing a Go module](https://go.dev/doc/modules/layout)
- [Table-driven tests](https://go.dev/wiki/TableDrivenTests)
- [Errors are values](https://go.dev/blog/errors-are-values)

## Names And Packages

- Prefer package names that are short, clear, and readable at call sites.
- Avoid stutter such as `foo.FooClient` when `foo.Client` is enough.
- Keep names boring and direct. Optimize for how the API reads in real code.
- Keep initialisms consistently cased: `URL`, `ID`, `HTTP`.
- Use short receiver names that stay consistent across methods.
- Write package comments and exported identifier comments that describe behavior and purpose.

## Types And Interfaces

- Start with concrete types.
- Define interfaces where they are consumed, not in a central "interfaces" file.
- Keep interfaces small and behavior-focused.
- Make the zero value useful when practical.
- Prefer concrete return types unless abstraction is part of the API contract.
- Use pointers when mutation, identity, or size make value semantics awkward; otherwise prefer values.
- Avoid embedding implementation details such as mutexes into exported structs.

## Errors

- Treat errors as part of the API surface.
- Keep error strings lower-case and without trailing punctuation.
- Wrap with `%w` only when the caller should be able to inspect the underlying cause.
- Hide implementation details with `%v` at boundaries where callers should not couple to internals.
- Use sentinel or typed errors only when callers need to branch on them.
- Handle each error once. Avoid logging and then returning the same failure.
- Add context while propagating errors instead of logging and continuing silently.

## Context And Concurrency

- Pass `context.Context` explicitly as the first parameter on request-scoped functions.
- Do not store contexts in structs.
- Use concurrency for a concrete benefit, not because the work merely can be parallelized.
- Prefer synchronous APIs unless concurrency is the actual contract.
- Keep channel ownership and closure responsibility obvious.
- Make cancellation, ownership, and shutdown behavior obvious.

## Tests

- Prefer table-driven tests for variant-heavy behavior.
- Use subtests to keep case naming readable.
- Mark helpers with `t.Helper()`.
- Produce failure messages that explain the expected behavior, not just the raw values.
- Use `t.Parallel()` only when test isolation is real.
- Prefer fuzzing for parsers, protocol handling, and input validation with large edge-case space.
- Add benchmarks only for hot paths or to protect a known performance property.

## Data And Standard Library Helpers

- Prefer nil slices unless a wire format requires an empty slice.
- Copy slices and maps when retaining caller-owned mutable data.
- Preallocate when size is known.
- Prefer `cmp`, `maps`, and `slices` over custom helpers when they fit.

## Modules

- Keep package and module boundaries simple and discoverable.
- Let directory structure reflect ownership and deployment boundaries, not hypothetical reuse.
- Avoid unnecessary dependencies and keep `go.mod` and `go.sum` tidy.
- Set the module `go` version intentionally rather than assuming the toolchain default is what you want.
