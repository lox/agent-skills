---
name: executing-plans
description: Implement one incremental slice from an existing engineering plan, validate it, run adversarial review and cleanup loops, publish a ready PR, and drive Codex review plus CI to passing.
---

# Executing Plans

Execute one plan slice end to end.

## Use This When

- The user asks to implement the next slice, first slice, or a named slice from an existing plan.
- The user wants plan execution to continue through validation, PR creation, Codex review, and CI cleanup.
- A `drafting-plans` plan already exists and should be treated as the sequencing source of truth.

## Required Companion Skills

Load and use these skills when available:

- `drafting-plans`: re-read the plan, preserve its sequencing, and update it when implementation changes scope, assumptions, validation, or progress.
- `adversarial-code-reviewing`: run a skeptical review after the slice implementation, then again after cleanup.
- `humanizing-text`: tighten PR titles, PR bodies, docs, and user-facing explanations so they sound like a human engineer wrote them.
- `autofixing-codex-reviews`: run the GitHub Codex review loop once the PR exists, including feedback replies, thread resolution, check monitoring, and fresh `@codex review` triggers.

If one of those skills is unavailable, follow the same workflow manually and say what was unavailable.

## Operating Stance

- Treat the plan as the working map, not a suggestion list. Do not reopen broad design unless repo evidence proves the plan is wrong.
- Prefer the next incomplete slice in the plan's own order unless the user names a specific slice.
- Keep the PR boundary slice-sized. Do not bundle unrelated cleanup or later phases.
- Verify cheap drift-prone facts against the current repo, branch, PR, docs, schema loaders, and CI state.
- Preserve user changes in dirty worktrees. Work with them unless they make the requested slice impossible.
- Stop only when the PR has passing checks, Codex has approved, and there is no pending review or actionable Codex feedback.

## Workflow

1. Resolve context.
   - Locate and read the plan in full, especially current state, delivery slices, validation, decisions, and open questions.
   - Inspect git status, current branch, existing PR state, and nearby code touched by the target slice.
   - If the plan lacks actionable slices, use `drafting-plans` to revise it before implementing.

2. Select the slice.
   - Choose the named slice or the next incomplete slice in plan order.
   - Write down the slice boundary for yourself: files likely touched, user-visible behavior, tests, docs, and PR scope.
   - Resolve blocking open questions with repo evidence first. Ask the user only when their judgment is required.

3. Implement the slice.
   - Make focused code, test, doc, schema, and example changes needed for the slice.
   - Follow existing repo patterns before inventing abstractions.
   - Update the plan when implementation changes the contract, sequencing, validation, or progress snapshot.

4. Validate the implementation.
   - Run the exact relevant tests, linters, schema checks, generated-code checks, or smoke tests from the plan and repo.
   - For docs or examples users can copy, validate them against the actual loader or parser when practical.
   - Fix failures before starting review.

5. Run the first adversarial review.
   - Use `adversarial-code-reviewing` against the slice diff, surrounding callers, tests, schemas, and operational boundaries.
   - Fix all material findings. Do not spend time on style while correctness, failure modes, security, or data integrity concerns remain.

6. Clean up deliberately.
   - Refactor only inside the slice boundary unless a shared helper is clearly required.
   - Improve names, structure, error handling, tests, and maintainability.
   - Apply SOLID principles where they reduce real coupling or make behavior easier to test. Do not add abstraction for its own sake.
   - Rerun relevant validation after cleanup.

7. Run the second adversarial review.
   - Review the post-cleanup diff with `adversarial-code-reviewing`.
   - Fix any remaining material issues and rerun the affected checks.

8. Publish a ready PR.
   - Commit with a conventional commit message and the repo's branch conventions.
   - Push the branch and create a non-draft PR.
   - Use a concise PR title in the repo's preferred form, for example `type: Summary`.
   - Use `humanizing-text` on the PR body. Keep it brief, public, and concrete: problem, solution, examples of use, validation, and plan slice covered.

9. Drive Codex review and CI to clean.
   - Trigger exactly one fresh `@codex review` after the PR is pushed and checks are passing or no local fix is possible.
   - Use `autofixing-codex-reviews` to wait for Codex, fix actionable feedback, reply with `Fixed in <sha>: ...`, react, resolve threads, and re-check CI.
   - If checks fail, inspect the failing jobs, fix the cause, push, and repeat the check loop.
   - Use a bounded loop. Stop and ask for guidance if Codex feedback conflicts, requires a product decision, or cannot be defended from the code.

## Definition of Done

The work is done only when:

- The chosen slice is implemented and validated.
- The plan reflects any material scope, validation, or progress changes.
- The PR is open, non-draft, and describes the problem, change, examples, and validation clearly.
- CI checks are passing.
- Codex review is approved, with no pending review or actionable Codex feedback.

Do not merge unless the user explicitly asks.

## Final Response

Report:

- PR URL and branch.
- Slice implemented.
- Validation run and results.
- Codex review and CI state.
- Any remaining risks or follow-up slices.

If the stop condition could not be reached, explain the blocker with concrete evidence and the next action.
