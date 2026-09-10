---
name: high-performance-zig
description: Writes, reviews, and optimizes high-performance Zig code with a measurement-first workflow, cache-aware layout, allocator discipline, comptime specialization, SIMD/scalar paths, and regression checks. Use for `.zig` changes where latency, throughput, memory, startup, binary size, or layout-sensitive code matters.
---

# High performance Zig

Make Zig code measurably faster. Start with the repository's toolchain, workload, and hot path. Make the smallest data-layout, allocator, comptime, or SIMD change supported by measurement.

## Load the reference

Read [references/performance-patterns.md](references/performance-patterns.md) before changing non-trivial performance-sensitive Zig code, reviewing performance, or making claims about cache behavior, struct layout, SIMD, allocators, or comptime cost.

## Order of work

1. Name the target: startup, steady-state throughput, tail latency, frame time, memory, binary size, build time, or CPU time for one workload.
2. Inspect the Zig version, `build.zig`, build options, target CPU and OS, benchmark harnesses, tests, allocators, and nearby data structures.
3. Find the hot path with a benchmark, trace, profile, or narrow reproducer. If none exists, add the smallest benchmark or test that detects a regression in the suspected path.
4. Trace allocations, ownership, pointer stability, hot and cold fields, cache-line sharing, branches, Unicode or protocol edge cases, syscalls, locks, and C API lifetime transfer.
5. Make one targeted change. Prefer repository helpers and Zig's standard library over new infrastructure.
6. Run the repository's checks and the relevant benchmark, size assertion, leak check, fuzz or synthetic input, or before-and-after profile.

Record the Zig version, release mode, target, workload, baseline, and relevant machine assumptions with results. Compare like with like. Do not use numbers from an unrepresentative debug build as production evidence.

## Optimization priorities

- Keep the common path explicit and cheap. Put rare cases on clear slow paths.
- Reduce allocations and use stable ownership and local buffers before adding custom pools.
- Use `std.MultiArrayList` or parallel arrays when a hot loop scans a few fields across many records. Keep arrays of structs when it consumes whole records.
- Use `packed struct` for dense flags, bit indexes, protocol fields, and frequently repeated tiny values. Avoid packed fields for frequently loaded natural-width integers or atomics unless measurement supports the tradeoff.
- Use `extern struct`, explicit `align(...)`, and `@sizeOf` tests for GPU buffers, C ABI boundaries, mmap or page formats, and other layout contracts.
- Use `std.atomic.cache_line` alignment or padding for hot atomics, per-thread counters, and buffers when false sharing or SIMD block alignment is measured or clear. Do not align every struct. Arrays of over-aligned small structs waste memory.
- Use comptime to remove platform or build-option branches, generate static tables from one source, and specialize types when this makes the API safer or smaller. Avoid `@Type` metaprogramming unless a central table or ABI contract justifies its compile-time cost.
- Keep SIMD behind the scalar path's public API. Test scalar and SIMD parity on malformed and boundary inputs.
- Treat C and GUI API boundaries as unsafe lifetime boundaries. Check performance memory tricks with leak-detecting allocators, Valgrind or Instruments where available, and regression tests for error paths.

## Review checklist

- Is there a named workload and a before/after number, or is this still speculation?
- Does the benchmark run in the right build mode and on the right target?
- Are hot structs sized and aligned intentionally, with `@sizeOf`, `@alignOf`, or `@offsetOf` assertions where drift would matter?
- Can any hot loop avoid allocation, logging, locks, virtual dispatch, hash lookups, or Unicode/general parser work on the common path?
- Are atomics naturally aligned, minimally shared across cache lines, and using the weakest correct ordering?
- Does every custom allocator, pool, mmap page, C allocation, and `errdefer` path have a test or tool-backed leak check?
- Is the faster path still correct for invalid input, large input, non-ASCII input, OOM, and platform-specific behavior?

## Report the result

State the measurement, optimization, and remaining limit. Mark faster-looking but unmeasured changes as unmeasured, and keep the simpler code until data supports them.
