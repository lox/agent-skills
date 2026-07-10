---
name: drafting-plans
description: Draft and revise durable engineering plans. Use for `docs/plans`, architecture, rollout, design docs, first-slice selection, open-question resolution, adversarial pressure-testing, and plan maintenance during implementation.
---

# Drafting Plans

Good plans are implementation maps: resumable, sequenced, and explicit about boundaries.

## Start With Local Evidence

- Inspect existing plan docs first. Prefer `docs/plans/`, and sample recent, similar-domain, and compact plans when available.
- Read relevant code, docs, schemas, runtime config, or issue/PR context before naming APIs, examples, commands, or validation.
- If the request continues an existing plan, treat that plan as the sequencing source of truth and update it in place unless the user asks for a new document.
- Put the plan where the user asked. If they ask for `docs/plans/`, create that path if needed rather than redirecting to another planning directory.
- When memory or prior context suggests decisions, verify cheap drift-prone facts against the current repo before writing them as current state.

## Default Shape

Follow the repository's structure first. Without a clear local convention, use this shape and omit low-signal sections:

1. Title and metadata: include a concise H1 plus plan frontmatter or the repository's existing visible metadata block.
2. Summary: explain the change and the intended user or operator outcome in a few concrete paragraphs.
3. Problem: state the current limitation, why it matters, and what breaks or stays awkward without the change.
4. Goals and non-goals: make scope explicit, especially what the first version deliberately refuses to solve.
5. Target model or proposal: describe the user-facing behavior, API, config, lifecycle, and ownership boundaries.
6. Safety model, invariants, or design principles: name the constraints that must not regress.
7. Backend, adapter, or subsystem notes: keep public contracts backend-neutral where practical, and put backend-specific details behind runtime config, adapter internals, or clearly labeled support boundaries.
8. Current state or progress snapshot: use this for ongoing work so later readers can tell what has landed, what is partial, and what remains.
9. Delivery strategy: break the work into independently reviewable slices with value after each slice.
10. Verification: list the unit, integration, smoke, schema, policy, performance, or runtime checks that prove the plan works.
11. Resolved decisions, deferred work, and open questions: separate decisions from speculation so future work can continue without reopening settled points.

## Plan Frontmatter

Prefer existing metadata style. If the repo uses visible lines under the title instead of YAML frontmatter, mirror that unless asked to standardize. For new YAML frontmatter:

```yaml
---
status: proposed
last_reviewed: 2026-05-03
spec_refs:
  - docs/spec.md
related_plans:
  - docs/plans/example.md
---
```

Fields:

- `status`: required; one of `proposed`, `active`, `paused`, `landed`, or `superseded`.
- `last_reviewed`: required `YYYY-MM-DD`; update on material revision or revalidation.
- `spec_refs`: optional specs, docs, schemas, or code references defining the contract.
- `related_plans`: optional plan docs this depends on, extends, or supersedes.
- `superseded_by`: required only for `status: superseded`.

Keep scope, phase status, questions, pressure-test learnings, and decisions in the body. Do not duplicate the H1 title unless tooling requires it.

## Update During Development

- Treat the plan as the working map, not a changelog. Update it when implementation changes scope, API, risks, or sequencing.
- When a slice lands, mark it landed or move it into the progress snapshot; keep remaining work in delivery strategy.
- When code proves the plan wrong, revise assumptions, examples, validation, and decisions in the same pass.
- Update `last_reviewed` after material revisions or revalidation. Change `status` only for lifecycle changes.
- Remove resolved open questions or move them to resolved decisions. Leave deferred questions only when they still affect later work.
- Do not add issue or PR metadata unless the repo requires it; status should stay readable from the document.

## Work Through Open Questions

After drafting or updating a plan, do not leave open questions as an inert parking lot when the user is still present. Run a short decision pass:

- Group questions by urgency: blocking the first slice, needed before a later phase, research required, or safe to defer.
- For each blocking question, recommend a default with the tradeoff in one or two sentences.
- Ask the user only the questions that need their judgment. Keep the batch small and concrete instead of asking them to react to the whole plan.
- When the user answers, update the plan immediately: move settled items to resolved decisions, adjust goals/non-goals or delivery slices, and leave only genuinely unresolved questions.
- If evidence can answer a question cheaply, inspect the repo, docs, schemas, runtime config, or host behavior before asking the user.
- If a question is not worth answering for the first slice, say where it is deferred and what would trigger revisiting it.

## Pressure-Test The Plan

After the first draft and open-question pass, run an adversarial review before treating the plan as done:

- Look for concrete ways the plan could fail: unsupported backends, hidden state, migration traps, cache invalidation, security exposure, race conditions, operator confusion, performance cliffs, missing observability, impossible testing, or examples that do not match current loaders.
- Ask why the team should not do this at all. Compare against simpler alternatives, deferring the work, narrowing the first slice, deleting the feature, or using an existing mechanism.
- Find fragile assumptions and name the evidence needed to keep or remove them.
- Identify complexity hotspots and decide whether they belong in the first slice, a later phase, or an explicit non-goal.
- Strengthen the plan based on the findings: adjust goals/non-goals, narrow public API, add fail-closed behavior, split delivery slices, add verification, or record rejected alternatives.
- Add a brief `Key Learnings From Pressure-Testing` section to the plan. Keep it concise: summarize the material risks discovered and the plan changes made because of them.
- Do not leave the adversarial pass as a separate critique if the plan can be improved directly. Patch the plan first, then summarize what changed.

## Good Plan Qualities

- It starts from real current behavior and names the smallest useful first slice plus follow-ups.
- It includes concrete CLI, YAML, proto, API, data model, or command examples when they clarify the contract.
- It explains public surface choices, including rejected alternatives when that prevents churn.
- It makes ownership boundaries explicit: user-facing policy versus runtime config, control plane versus backend, host service versus guest behavior, transport cache versus environment cache.
- It has fail-closed behavior for unsupported or partially implemented backends instead of silent widening or best-effort semantics.
- It distinguishes exact implementation work from optional later convenience features.
- It defines risk-matched validation and records decisions/open questions near the end.

## Delivery Slices

- Prefer phases, slices, or PR-sized tracks over one large checklist.
- Each slice should have a clear scope and a definition of done when correctness is not obvious.
- Put prerequisites before dependent work, and call them out as merged, active, or follow-up when the plan is already underway.
- Keep the first slice boring and demonstrably useful. Avoid planning a broad framework before the first user-visible behavior or invariant is landed.
- If a slice touches docs or examples that users can copy, include validation against the implemented schema or loader.

## Style

- Use direct engineering prose. Avoid marketing copy, generic architecture filler, and unexplained abstractions.
- Prefer short paragraphs and focused bullets. Long plans are fine when the system surface is large, but every section should earn its space.
- Use code blocks for real contracts, not decoration.
- Keep examples public and generic unless the user explicitly asks for private context.
- Preserve local naming and capitalization conventions for commands, packages, statuses, and headings.
- If the plan is for an early-stage repo, do not add compatibility scaffolding unless the user asks for it.

## When Asked For The First Slice

- Re-read the plan's delivery strategy and current progress before answering.
- Identify the next incomplete phase in the plan's own order.
- Answer with the concrete files, commands, tests, and expected PR boundary for that slice.
- If the user approves execution, implement that slice instead of reopening the whole plan.

## Avoid

- A task list with no problem statement, non-goals, invariants, or validation.
- A broad "mode" or generic abstraction when explicit contracts would be clearer.
- Config examples that imply behavior the current loader or runtime does not read.
- Backend-specific public API when a backend-neutral contract would work.
- Open questions mixed into settled decisions.
- Treating open questions as the end state when the user is available to resolve them.
- Treating adversarial review as commentary only instead of using it to improve the plan.
- Future phases that are more detailed than the first actionable slice.
