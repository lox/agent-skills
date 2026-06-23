# High Performance Zig Patterns

This reference is for performance-sensitive Zig implementation and review. It distills patterns from Mitchell Hashimoto's Zig/Ghostty writing and a Ghostty source review, but the rule stays simple: measure first, then make the smallest change that moves the number.

## Research Anchors

- Mitchell Hashimoto, ["Talk: Introducing Ghostty and Some Useful Zig Patterns"](https://mitchellh.com/writing/ghostty-and-useful-zig-patterns) - comptime data tables, generated types, and C ABI architecture.
- Mitchell Hashimoto, ["Ghostty Devlog 006"](https://mitchellh.com/writing/ghostty-devlog-006) - IO throughput, SIMD UTF-8, table-driven width calculation, and CSI fast paths.
- Mitchell Hashimoto, ["Zig Parser"](https://mitchellh.com/zig/parser) - `MultiArrayList` for lower padding waste and better cache locality.
- Mitchell Hashimoto, ["Finding and Fixing Ghostty's Largest Memory Leak"](https://mitchellh.com/writing/ghostty-memory-leak-fix) - page-aligned `mmap`, pools, non-standard page cleanup, VM tags, and leak validation.
- Mitchell Hashimoto, ["Don't Trip[wire] Yourself"](https://mitchellh.com/writing/tripwire) - zero-cost test-only failure injection for `errdefer` paths.
- Mitchell Hashimoto, ["Conditionally Disabling Code with Comptime in Zig"](https://mitchellh.com/writing/zig-comptime-conditional-disable) and ["Tagged Union Subsets with Comptime in Zig"](https://mitchellh.com/writing/zig-comptime-tagged-union-subset) - compile-time code elimination and generated type safety.
- [Ghostty source snapshot](https://github.com/ghostty-org/ghostty/tree/4789bbd) reviewed at commit `4789bbd`.
- Zig 0.16 [language reference](https://ziglang.org/documentation/0.16.0/#Alignment) and [`std.atomic.cache_line`](https://github.com/ziglang/zig/blob/master/lib/std/atomic.zig) source for alignment, atomics, and false-sharing guidance.

## Measurement Discipline

Define which "fast" matters before changing code. Ghostty separates startup time, IO throughput, control-sequence throughput, frame rate, memory usage, and build time; optimize one at a time. A change that wins for bulk UTF-8 throughput can be irrelevant to input latency.

Use the narrowest real workload:

- Parser or decoder: replay captured bytes, malformed input, and representative large files.
- Renderer: measure frame time, upload bytes, buffer rebuild cost, and shader parameter size.
- Allocator or pool: count allocations, bytes, peak RSS/VM regions, and deinit behavior.
- Build/comptime: time `zig build --help`, test rebuilds, and affected modules.

Use release-mode numbers for speed claims. Keep debug/test builds for leak detection, safety checks, and invariant testing.

## Data Layout

Start with access pattern, not syntax:

1. List the hot fields actually read or written in the loop.
2. Split hot fields from cold metadata if cold fields inflate cache footprint.
3. Choose AoS when each operation consumes the whole record.
4. Choose SoA, `std.MultiArrayList`, or parallel arrays when loops scan one or two fields across many records.
5. Add `@sizeOf`, `@alignOf`, `@offsetOf`, or field-bit assertions where changing layout changes performance, ABI, disk/network format, GPU upload format, or memory budget.

Use normal `struct` for ordinary internal data. Use `extern struct` when field order and ABI layout are the contract. Use `packed struct` when exact bit layout or dense flags are the contract.

Packed structs are not a free speed button. They can reduce bytes and cache footprint, but they can also force awkward loads, reduce natural alignment, and make atomics invalid or slower. Prefer packed fields for booleans, enum tags, masks, protocol fields, and tiny identifiers that are stored everywhere.

When a hot record is stored in an array and must not cross cache lines, make the budget explicit. The robust patterns are:

- Make `@sizeOf(T)` divide `std.atomic.cache_line`, align the array allocation to the cache line, and assert both facts.
- Or intentionally pad/align one instance per cache line for contended atomics or per-thread counters.
- Or stop fighting AoS and use SoA so the hot lane is a naturally aligned array of primitive values.

Do not align every small type to a cache line. Arrays of cache-line-aligned structs round each element up and can destroy cache density.

## Alignment And Cache Lines

Use `@alignOf(T)` to learn the natural alignment for the target. Use `@alignCast` only when you know a pointer is more aligned than its type says; Zig inserts a safety check. For atomic compare-exchange, Zig requires pointer alignment at least `@sizeOf(T)`.

Use `std.atomic.cache_line` for estimated cache-line alignment when the code is about atomics or false sharing. Good cases:

- Read/write buffers consumed by hot parsers or benchmark readers.
- Per-thread counters or queues written by different cores.
- Atomics next to unrelated hot non-atomic data.
- SIMD blocks that benefit from a stronger alignment guarantee.

Bad cases:

- Cold structs.
- Small immutable lookup records.
- Values allocated one at a time where fragmentation costs more than any line-crossing benefit.
- Layout changes without a benchmark or an assertion.

Ghostty examples to mirror:

- Cache-line-aligned benchmark buffers: `[4096]u8 align(std.atomic.cache_line)`.
- Renderer/GPU ABI structs with explicit field alignment and `@sizeOf` tests.
- Packed font indexes with fixed backing integers and tests for bit budgets.

## Allocators, Pools, And Pages

Allocator choice is part of API design in Zig. Before adding a pool, answer:

- Is allocation on the hot path by profile or count?
- Are allocation sizes bounded and repetitive?
- Is pointer stability required?
- Can the pool be reset or deinitialized safely on every error path?
- What happens to rare larger-than-standard allocations?

Ghostty's PageList pattern is useful: standard page-sized buffers come from a page-aligned pool; non-standard oversized pages bypass the pool and must be freed directly. The bug class to avoid is metadata drift: if metadata says "standard pooled page" while the allocation is actually a larger direct mmap, teardown leaks. Keep allocation class and deallocation class tied together in data, not inferred from stale metadata.

Use `std.testing.allocator` in tests when possible. Use Valgrind or platform profilers when C APIs, GUI frameworks, `mmap`, or custom allocators enter the path. On macOS, VM tags can make large allocator families visible in Instruments and `vmmap`.

Pool only the stable, common shape. Destroy or separately manage rare non-standard shapes until measurements justify a more complex reuse policy.

## Comptime

Use comptime for zero-runtime specialization:

- Platform or feature code elimination: `if (comptime options.simd)`.
- Build-option branches that should not leave runtime conditionals.
- Static maps and generated tables from one canonical source.
- Type-safe unions/enums generated from existing action/capability tables.
- Test-only instrumentation that compiles away outside `builtin.is_test`.

Keep `@Type`, `@unionInit`, and `inline else` localized. They are worth it when they centralize a large table, produce compiler-enforced exhaustiveness, preserve ABI shape, or remove duplicated runtime code. They are not worth it for one-off cleverness.

Add size or exhaustiveness tests around generated types. If a backing integer grows, a C ABI union changes size, or a font/index bit budget shrinks, the test should make that visible.

## SIMD And Fast Paths

Fast path the common bytes first. In terminal/parser workloads, ASCII and well-formed UTF-8 often dominate; malformed, incomplete, or escape-heavy input still has to be correct.

A good SIMD shape:

- One public Zig function.
- `if (comptime options.simd)` branch to the SIMD implementation.
- Scalar fallback in Zig.
- Tests and fuzz cases that exercise both slice/SIMD and scalar byte-at-a-time paths.
- Boundary cases: empty input, partial UTF-8 at buffer end, invalid leading bytes, control bytes, and output capacity.

Do not add a SIMD dependency just because it exists. If the repo already uses simdutf, Highway, or target intrinsics, reuse that path. Otherwise, prove that scalar code, table lookup, or simpler batching is not enough.

## Hot Loop Hygiene

For each hot loop, check:

- No allocation unless allocation is the point of the benchmark.
- No logging or formatting.
- No unnecessary UTF-8/codepoint/grapheme work on ASCII or single-byte paths.
- No hash lookup when a table, enum, dense array, or generated static map would work.
- No lock on the uncontended/common enqueue path.
- No repeated branch on a compile-time-known build option.
- No function call retained after a no-op test/debug path should compile away.

Prefer tables for stable classification work such as width, symbol, ASCII, or protocol capability lookup. Correct table lookups can beat a "simple" libc call when the libc call is wrong for the domain or burns branches.

## Error Paths Are Performance Code

High-performance Zig often owns memory manually. Error cleanup is therefore part of correctness, not polish.

Use `errdefer` directly after each successful acquisition. For complex init functions, add test-only fail points before fallible operations so each `errdefer` can be exercised. Mitchell's Tripwire pattern uses `builtin.is_test` and inline/no-op call conventions so the checks produce no runtime code outside tests.

At minimum, tests should prove:

- OOM or injected failure frees prior allocations.
- Pools return borrowed entries on failed init.
- C handles, mmap pages, file descriptors, and GPU objects release on partial failure.
- Success-path cleanup and error-path cleanup do not double free.

## C ABI And Platform Boundaries

Zig makes C interop cheap, but C API lifetimes are still a trust boundary. Use `extern struct` and explicit `C` conversion types for exported ABI. Assert ABI sizes when caller compatibility depends on them.

For platform GUI and graphics APIs:

- Copy documented alignments into Zig types instead of hoping default layout matches.
- Keep a single conversion layer between internal Zig types and C/Swift/GTK/Metal/OpenGL types.
- Document who owns each pointer and which function releases it.
- Run tooling that can see across the boundary: Valgrind for GTK/C paths, Instruments for macOS/Swift/CoreText paths, and leak-detecting Zig allocators for pure Zig tests.

## Minimal Review Template

Use this shape when reviewing performance-sensitive Zig:

```text
Workload: <what was measured>
Current bottleneck: <allocation/cache/branch/syscall/parser/render/upload/etc>
Smallest useful change: <one targeted change>
Required proof: <benchmark/test/assert/profile>
Risk: <correctness/platform/ABI/memory/build-time risk>
Ceiling: <what to revisit only if this still shows up>
```

If the workload and proof fields are empty, do not recommend a large rewrite. Add the measurement first.
