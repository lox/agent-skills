---
name: simplicity-review
description: Reviews changes for unnecessary code and structural complexity, judging whether new code, abstractions, dependencies, or configuration need to exist. Use for YAGNI, simplicity, minimalism, maintainability, over-engineering, deep code-quality, or explicitly harsh and thermo-nuclear reviews.
---

# Simplicity review

Review a change with one question: does every line, concept, and layer in the diff earn its existence? The best code is code that does not need to exist; the next best code replaces more concepts than it adds.

Read the changed code and enough surrounding context to understand what the change must accomplish before judging what could be smaller. Leave correctness, security, and failure modes to a ship-risk lens. Do not recommend deletion that weakens required behavior.

When the user explicitly asks for a thermo-nuclear, thermonuclear, especially harsh, or deep code-quality review, apply this same evidence standard with an unusually strict maintainability stance. Push harder on structural simplification, but do not manufacture findings or recommend rewrites the diff and repository context do not support.

## Remedy ladder

For each meaningful part of the diff, find the lowest rung that covers the need. Flag a change when it stopped higher without evidence:

1. Delete or defer speculative features, configuration, generality, or scaffolding with no present caller.
2. Reuse an existing helper, type, module, or repository pattern.
3. Use the standard library or an idiomatic built-in.
4. Use a native platform feature: CSS over JavaScript, a database constraint over application code, or a built-in control over another UI dependency.
5. Use an already-installed dependency before adding a package.
6. Prefer a short idiomatic expression over a bespoke abstraction.
7. Add the minimum direct, boring code needed for current requirements.
8. Add structure (a helper, typed model, dispatcher, or module split) only when repeated conditionals, scattered feature checks, duplicated branches, or poor ownership show a missing model, and the result leaves the reader holding fewer concepts.

An abstraction must earn its keep. Indirection alone is not simplification.

## Strong signals

Flag cases, backed by the code, where the diff:

- ships generality "for later," or adds an interface, factory, option, or configuration value for one implementation or one fixed value
- reimplements something already supplied by the repository, standard library, platform, or an installed dependency
- adds a dependency for a few clear idiomatic lines
- introduces thin wrappers, pass-through helpers, identity abstractions, or generic machinery that hide a simpler data shape
- adds one-off booleans, nullable modes, ad hoc conditionals, or scattered feature checks instead of clarifying the model
- leaks feature-specific logic into shared code or the wrong owner
- patches one caller or symptom when a shared root is the smaller correct fix
- uses casts, optional parameters, silent fallbacks, or magic defaults instead of an explicit contract
- chooses the shortest diff in the wrong layer; small and misplaced is not simple
- adds non-trivial logic without the smallest useful check that would fail if it broke
- relocates complexity without reducing the concepts a maintainer must understand

Treat file size as a prompt to inspect cohesion, not a defect by itself. New structure is justified only when it improves ownership and reduces total conceptual load.

## Do not simplify away

Do not remove input validation at trust boundaries, error handling that prevents data loss, security or accessibility requirements, calibration controls for real hardware or environment drift, observability needed to operate the system, or behavior explicitly required by the change.

Between equally small approaches, prefer the one that remains correct at the relevant edges. Trivial one-liners need no test; one focused assertion is often enough for a narrow behavior.

## Output

Write per `writing-plainly`. Report only findings tied to specific code in the diff. Each finding is one short paragraph that says what does not need to exist or what got harder to follow, why that costs the next maintainer, and the smaller replacement at the lowest remedy-ladder rung, including deletion when that is the answer.

> `internal/retry/policy.go` adds a `Policy` interface, a `DefaultPolicy` struct, and a factory for the one backoff schedule the code uses. Delete all three and call `backoff.Retry(ctx, fn, 3, 100*time.Millisecond)` from the two call sites; add the interface when a second schedule exists.

Prefer one strong deletion or reframing over several nits. Be direct without being rude. If the diff is already minimal, idiomatic, and well placed, say so in a sentence and stop.
