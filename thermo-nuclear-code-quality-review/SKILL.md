---
name: thermo-nuclear-code-quality-review
description: Run an extremely strict maintainability review for abstraction quality, giant files, and spaghetti-condition growth. Use for a thermo-nuclear code quality review, thermonuclear review, deep code quality audit, or especially harsh maintainability review.
disable-model-invocation: true
---

# Thermo-Nuclear Code Quality Review

Use this skill for an unusually strict review focused on implementation quality, maintainability, abstraction quality, and codebase health.

Above all, push for ambitious structural simplification. Do not stop at local cleanup if the change can be reframed so whole branches, helper layers, modes, or incidental concepts disappear while behavior stays the same.

## Review Stance

- Treat "it works" as insufficient when the implementation makes the codebase harder to change safely.
- Look for "code judo" moves: reorganizations that make the solution feel simpler and inevitable in hindsight.
- Prefer deleting complexity over moving it around.
- Prefer direct, boring, maintainable code over hacky, magical, generic, or cast-heavy code.
- Prefer a small set of high-conviction structural findings over a long list of cosmetic nits.

## Presumptive Blockers

Push back hard when a change:

- pushes a file from below 1k lines to above 1k lines without a strong structural reason
- adds ad-hoc conditionals, one-off booleans, nullable modes, or scattered feature checks into unrelated flows
- leaks feature-specific logic into shared modules or the wrong package/layer
- introduces thin wrappers, identity abstractions, pass-through helpers, or generic magic that hide a simpler data shape
- uses unnecessary casts, `any`, `unknown`, optional params, or silent fallbacks instead of making the contract explicit
- duplicates existing helpers or ignores the canonical local abstraction
- serializes independent work or leaves related updates non-atomic when a cleaner structure is obvious
- refactors by relocating complexity without reducing the number of concepts a reader must hold

## Review Questions

For every meaningful change, ask:

- Can this be reframed so fewer concepts, branches, helpers, or layers are needed?
- Did the diff make a cohesive module more coupled, more stateful, or harder to scan?
- Is this logic in the right file, package, service, or layer?
- Are repeated conditionals signaling a missing model, helper, dispatcher, or state machine?
- Is this abstraction earning its keep, or is it just indirection?
- Could a clearer type boundary remove fallback-heavy or special-case control flow?
- Would decomposition, helper extraction, or ownership changes make this materially simpler?

## Preferred Remedies

Prefer remedies that:

- delete a layer of indirection
- collapse duplicate branches into one clearer flow
- reframe the state model so conditionals disappear
- move logic to the module that already owns the concept
- extract a focused helper, pure function, subcomponent, or module
- replace condition chains with an explicit typed model or dispatcher
- separate orchestration from business logic
- make related updates more atomic

## Output

Findings must explain:

1. what structural quality regressed
2. why that regression matters for future change safety
3. what concrete simplification or decomposition should replace it

Be direct and demanding about quality without being rude. Do not approve merely because behavior appears correct. Avoid style-only feedback unless there are no larger structural concerns.
