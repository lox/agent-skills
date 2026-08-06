---
name: high-performance-zig
description: Writes, reviews, and optimizes high-performance Zig code with a measurement-first workflow, cache-aware layout, allocator discipline, comptime specialization, SIMD/scalar paths, and regression checks. Use for `.zig` changes where latency, throughput, memory, startup, binary size, or layout-sensitive code matters.
---

# High Performance Zig

Use this skill to make Zig code measurably faster without turning it into folklore. Start from the repository's real toolchain, workload, and hot path; then apply the smallest data-layout, allocator, comptime, or SIMD change that the measurement supports.

## Load The Reference

Read [references/performance-patterns.md](references/performance-patterns.md) before changing non-trivial performance-sensitive Zig code, doing a performance review, or making claims about cache behavior, struct layout, SIMD, allocators, or comptime cost.

## Work In This Order

1. Identify the performance target: startup, steady-state throughput, tail latency, frame time, memory footprint, binary size, build time, or CPU time in one named workload.
2. Inspect local context first: Zig version, `build.zig`, build options, target CPU/OS, benchmark harnesses, tests, allocators, and adjacent data structures.
3. Find the hot path with an existing benchmark, trace, profile, or narrow reproducer. If none exists, add the smallest benchmark or test that can fail when the suspected path regresses.
4. Trace data movement before editing: allocations, ownership, pointer stability, hot/cold fields, cache-line sharing, branch shape, Unicode/protocol edge cases, syscalls, locks, and C API lifetime transfer.
5. Apply one targeted optimization at a time, preferring existing repo helpers and Zig standard library facilities over new infrastructure.
6. Prove the result with the repo's normal checks plus a focused benchmark, size assertion, leak check, fuzz/synthetic input, or before/after profile as appropriate.

Record the Zig version, release mode, target, workload, baseline, and relevant machine assumptions with benchmark results. Compare like with like, and do not present numbers from an unrepresentative debug build as production evidence.

## Optimization Priorities

- Keep the common path explicit and cheap. Put rare cases behind clear slow paths.
- Prefer fewer allocations, stable ownership, and local buffers before custom pools.
- Use `std.MultiArrayList` or parallel arrays when a hot loop scans a few fields from many records; keep array-of-structs when the loop consumes whole records.
- Use `packed struct` for dense flags, bit indexes, protocol fields, and high-fanout tiny values. Avoid packed fields for frequently loaded natural-width integers or atomics unless the access pattern proves it is worth the tradeoff.
- Use `extern struct` plus explicit `align(...)` and `@sizeOf` tests for GPU buffers, C ABI surfaces, mmap/page formats, and other layout contracts.
- Use `std.atomic.cache_line` alignment or padding for hot atomics, per-thread counters, and buffers where false sharing or SIMD block alignment is measured or obvious. Do not cache-line-align every struct; arrays of over-aligned small structs waste memory quickly.
- Use comptime to remove platform/build-option branches, generate static tables from one source of truth, and specialize types when the generated API is safer or smaller. Avoid `@Type` metaprogramming unless a centralized table or ABI contract justifies the compile-time complexity.
- Keep SIMD behind the same public API as the scalar path. Test scalar/SIMD parity on malformed and boundary inputs.
- Treat C and GUI API boundaries as unsafe lifetime boundaries. Pair performance memory tricks with leak-detecting allocators, Valgrind/Instruments where available, and regression tests that exercise error paths.

## Review Checklist

- Is there a named workload and a before/after number, or is this still speculation?
- Does the benchmark run in the right build mode and on the right target?
- Are hot structs sized and aligned intentionally, with `@sizeOf`, `@alignOf`, or `@offsetOf` assertions where drift would matter?
- Can any hot loop avoid allocation, logging, locks, virtual dispatch, hash lookups, or Unicode/general parser work on the common path?
- Are atomics naturally aligned, minimally shared across cache lines, and using the weakest correct ordering?
- Does every custom allocator, pool, mmap page, C allocation, and `errdefer` path have a test or tool-backed leak check?
- Is the faster path still correct for invalid input, large input, non-ASCII input, OOM, and platform-specific behavior?

## Output Expectations

State the measurement, the optimization, and the remaining ceiling. If a faster-looking change is unmeasured, say so and prefer the simpler code until the data exists.
