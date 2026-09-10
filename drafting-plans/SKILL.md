---
name: drafting-plans
description: Drafts and revises concise, durable engineering plans. Use for `docs/plans`, architecture, rollout or design docs, first-slice selection, open-question resolution, plan review, or plan maintenance during implementation.
---

# Drafting plans

A plan is a map for the person implementing the work, not a record of planning. Make it specific enough to resume from and no longer than that.

## Start from evidence

Read the repository's plan conventions and the relevant code, docs, schemas, config, and issue or PR context before naming a contract or command. Verify cheap, drift-prone facts before stating them as current. If a plan already owns the work, update it in place. Put the plan where the user asked, keep the repository's metadata and formatting, and do not invent frontmatter, lifecycle fields, or dates the repository does not use.

## Shape

Follow the repository's convention. Otherwise use the smallest useful subset of these, in this order, with no empty headings:

1. Problem: the current limitation and why it matters.
2. Approach: the intended behavior, the contracts that matter, and who owns what.
3. Scope and non-goals.
4. Delivery slices: independently reviewable steps, smallest useful slice first.
5. Decisions, risks, and open questions that affect implementation or order.

Add rollout, migration, safety, compatibility, observability, verification, or progress sections only when the work needs them. "Overview", "Background", and "Context" headings earn a place only when they carry something the reader needs before the problem.

## Decide

Answer questions from the repository when you can. For a question that needs the user, recommend a default and give the tradeoff in a sentence, and ask in a small batch rather than listing inert questions. Record settled decisions where they apply in the plan. Leave a question open only when it still affects later work, and say what resolves it.

Pressure-test the plan when the user asks or when the work is risky, cross-cutting, hard to reverse, migration-heavy, or security-sensitive. Ask whether it should be smaller, later, deleted, or built on something that exists. Put what you learn into scope, approach, risks, or slices. Do not add a "Key Learnings", alternatives, risk-matrix, or review section.

## Slices and maintenance

Put prerequisites first and make each slice useful or correctness-preserving on its own. Keep the first slice boring and concrete. Do not design later phases in more detail than the next slice. Include exact files, contracts, commands, and checks only when they remove ambiguity. When implementation changes scope, contracts, risk, order, or progress, update the plan and delete what is stale; do not append a changelog. When asked for the first or next slice, take it from the plan and proceed when authorized instead of reopening the design.

## Style

Write per `writing-plainly`. Name the problem in the reader's terms and the code's names. Leave out architecture filler, speculative abstractions, decorative examples, and compatibility scaffolding no requirement asks for.
