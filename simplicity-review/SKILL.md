---
name: simplicity-review
description: Reviews changes for unnecessary code and structural complexity, judging whether new code, abstractions, dependencies, or configuration need to exist. Use for YAGNI, simplicity, minimalism, maintainability, over-engineering, deep code-quality, or explicitly harsh and thermo-nuclear reviews.
---

# Simplicity review

Ask one question of every line, concept, and layer in the diff: does it need to exist? The best code is code that does not exist. The next best replaces more concepts than it adds.

Read the changed code and enough context to know what the change must do before judging what could be smaller. Leave correctness, security, and failure modes to a ship-risk review.

When the user asks for a thermo-nuclear, especially harsh, or deep code-quality review, hold the same evidence standard with a stricter maintainability stance. Push harder on structure. Do not manufacture findings or recommend rewrites the diff does not support.

## Remedy ladder

For each part of the diff, find the lowest rung that covers the need. Flag the change when it stopped higher without a reason.

1. Delete or defer anything with no present caller: speculative features, config, generality, scaffolding.
2. Reuse an existing helper, type, module, or repository pattern.
3. Use the standard library or an idiomatic built-in.
4. Use a native platform feature: CSS over JavaScript, a database constraint over application code, a built-in control over a UI dependency.
5. Use an already-installed dependency before adding one.
6. Prefer a short idiomatic expression over a bespoke abstraction.
7. Add the minimum direct, boring code for the current requirement.
8. Add structure (a helper, typed model, dispatcher, or module split) only when repeated conditionals, scattered feature checks, or unclear ownership show a missing model, and the result leaves the reader holding fewer concepts.

Indirection is not simplification. New structure earns its place only by reducing what a maintainer must hold in their head.

## Signals

Flag, with the code as evidence, a diff that:

- ships generality for later, or an interface, factory, option, or config value with one implementation or one fixed value
- reimplements something the repository, standard library, platform, or an installed dependency already provides
- adds a dependency for a few idiomatic lines
- adds thin wrappers, pass-through helpers, or generic machinery that hides a simpler data shape
- adds one-off booleans, nullable modes, or scattered feature checks instead of fixing the model
- puts feature-specific logic in shared code or the wrong owner
- patches one caller or symptom when the shared root is the smaller fix
- uses casts, optional parameters, silent fallbacks, or magic defaults instead of an explicit contract
- picks the shortest diff in the wrong layer; small and misplaced is not simple
- adds non-trivial logic without the one check that would fail if it broke
- moves complexity without reducing it

File size alone is not a defect. Inspect cohesion instead.

## Do not simplify away

Input validation at trust boundaries, error handling that prevents data loss, security or accessibility requirements, calibration for real hardware or environment drift, observability needed to run the system, and behavior the change is required to have. Between equally small approaches, prefer the one that stays correct at the edges. Trivial one-liners need no test; one focused assertion usually covers a narrow behavior.

## Output

Write per `writing-plainly`. Report only findings tied to specific code in the diff. Each finding is one short paragraph: what does not need to exist or got harder to follow, what it costs the next maintainer, and the smaller replacement at the lowest rung, including deletion.

> `internal/retry/policy.go` adds a `Policy` interface, a `DefaultPolicy` struct, and a factory for the one backoff schedule the code uses. Delete all three and call `backoff.Retry(ctx, fn, 3, 100*time.Millisecond)` from the two call sites; add the interface when a second schedule exists.

One strong deletion beats several nits. Be direct, not rude. If the diff is already minimal and well placed, say so in a sentence and stop.
