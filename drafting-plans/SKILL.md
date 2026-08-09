---
name: drafting-plans
description: Drafts and revises concise, durable engineering plans. Use for `docs/plans`, architecture, rollout or design docs, first-slice selection, open-question resolution, plan review, or plan maintenance during implementation.
---

# Drafting Plans

A plan is an implementation map, not a record of planning ceremony. Make it resumable and specific while including only sections the work needs.

## Start With Evidence

- Inspect existing plan conventions and relevant code, docs, schemas, configuration, issue, or PR context before naming contracts or commands.
- Update an existing plan in place when it already owns the work.
- Put the plan where the user asked. Preserve repository metadata and formatting conventions; do not invent frontmatter, lifecycle fields, or dates when the repository does not require them.
- Verify cheap, drift-prone facts before presenting them as current state.

## Default Shape

Follow repository convention first. Otherwise use the smallest useful subset of:

1. **Problem / why**: the current limitation and why it matters.
2. **Proposed approach**: the intended behavior, important contracts, and ownership boundaries.
3. **Scope and non-goals**: what this work will and deliberately will not solve.
4. **Delivery slices**: independently reviewable steps, starting with the smallest useful slice.
5. **Decisions, risks, or open questions**: only items that affect implementation or sequencing.

Omit empty headings. Add rollout, migration, safety, compatibility, observability, verification, backend notes, or progress sections only when the change actually needs them.

## Resolve Decisions

- Answer questions from repository evidence when practical.
- For blocking questions that need user judgement, recommend a default and explain the tradeoff briefly. Ask a small concrete batch rather than presenting an inert question list.
- Record settled decisions in the relevant part of the plan. Leave an open question only when it still affects later work, and say what must resolve it.

## Pressure-Test Proportionally

Pressure-test when the user asks or when the plan is materially risky, cross-cutting, expensive to reverse, migration-heavy, security-sensitive, or operationally complex. Check whether the work should be smaller, deferred, deleted, or built on an existing mechanism.

Integrate useful findings into scope, approach, risks, or slices. Do not automatically add a “Key Learnings,” alternatives, risk matrix, or adversarial-review section.

## Delivery And Maintenance

- Put prerequisites before dependent work and make each slice useful or correctness-preserving on its own.
- Keep the first slice boring and concrete. Do not design later phases in more detail than the next actionable slice.
- Include exact files, contracts, examples, commands, and checks only when they make implementation less ambiguous.
- Update the plan when implementation changes scope, contracts, risks, sequencing, or progress. Remove stale assumptions and resolved questions rather than appending a changelog.
- When asked for the first or next slice, identify it from the plan and proceed to implementation when authorized instead of reopening the design.

## Style

Use direct engineering prose, short paragraphs, and focused bullets. Avoid generic architecture filler, speculative abstractions, decorative examples, and compatibility scaffolding without a present requirement.
