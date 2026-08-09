---
name: executing-plans
description: Executes engineering plans locally, slice by slice. Use when asked to implement, continue, or iterate on an existing plan through focused changes, validation, review, plan updates, and an optional commit or PR workflow.
---

# Executing Plans

Execute plan slices locally by default.

## Use This When

- The user asks to implement the next slice, first slice, or a named slice from an existing plan.
- The user asks to keep executing or iterating on an existing plan.
- The user wants local branch work to proceed through validation, review, cleanup, and slice commits before any PR exists.
- A `drafting-plans` plan already exists and should be treated as the sequencing source of truth.

## Required Companion Skills

Load and use these skills when available:

- `drafting-plans`: re-read and update the plan when scope, assumptions, validation, or progress changes.
- `auto-review`: review the current-slice diff, fix grounded findings, validate, and repeat until ready or blocked.

If one of those skills is unavailable, follow the same workflow manually and say what was unavailable.

## Optional Companion Skills

Load these only when the workflow needs them:

- `writing-pr-descriptions`: use when the user asks to publish or update a PR.
- `babysitting-prs`: use only when the user explicitly asks to babysit, make merge-ready, land, merge, or otherwise drive an existing PR through review and CI. Use ready-only mode unless the user explicitly asks to merge.
- `work-walkthrough`: use only when the user explicitly asks for a demo, walkthrough, showcase, or substantial handoff.

## Operating Stance

- Treat the plan as the working map, not a suggestion list. Do not reopen broad design unless repo evidence proves the plan is wrong.
- Work locally on a branch by default. Do not push, publish a PR, request PR review, or babysit a PR unless the user asks for that.
- Prefer the next incomplete slice in the plan's own order unless the user names a specific slice or slice set.
- If the user asks for one slice, stop after that slice is complete. If they ask to execute or continue the plan generally, keep taking the next incomplete slice until done, blocked, or out of scope.
- Follow the repository's commit policy. Commit each completed slice only when the user or repository workflow expects slice commits; otherwise keep logical slice boundaries in the diff and handoff.
- Verify cheap drift-prone facts against the current repo, branch, docs, schema loaders, and any PR or CI state that is already in scope.
- Preserve user changes in dirty worktrees. Work with them unless they make the requested slice impossible.
- Pause before destructive migrations, credential-dependent work, unexplained scope growth, or choices whose product or operational consequences cannot be resolved from repository evidence.

## Workflow

1. Resolve context.
   - Locate and read the plan in full, especially current state, slices, validation, decisions, and open questions.
   - Inspect git status, current branch, existing PR state if any, and nearby code touched by the target slice.
   - If the worktree is detached, on the default branch, or otherwise not on an appropriate work branch, create or switch to a local branch using the repo's branch conventions. Do not push it by default.
   - If the plan lacks actionable slices, use `drafting-plans` to revise it before implementing.

2. Select the target slice set.
   - If the user names specific slices, implement only those slices.
   - If the user asks for the next, first, or a named slice, implement only that slice.
   - If the user asks to execute or continue the plan without narrowing the target, start with the next incomplete slice and continue after each completed slice.
   - Write down the current slice boundary for yourself: files likely touched, user-visible behavior, tests, docs, and commit scope.
   - Resolve blocking open questions with repo evidence first. Ask the user only when their judgment is required.

3. Implement the slice.
   - Make focused code, test, doc, schema, and example changes needed for the slice.
   - Follow existing repo patterns before inventing abstractions.
   - Update the plan when implementation changes the contract, sequencing, validation, or progress snapshot.

4. Validate the implementation.
   - Run the exact relevant tests, linters, schema checks, generated-code checks, or smoke tests from the plan and repo.
   - For copyable docs or examples, validate them against the actual loader or parser when practical.
   - Fix failures before starting review.

5. Run `auto-review`.
   - Use `auto-review` against the current-slice diff. Use a branch-wide target only before an explicitly requested PR, handoff, or readiness check.
   - Fix grounded findings inside the slice boundary, rerun relevant validation, and let `auto-review` re-review after the last edit.
   - If any fix changes the plan, docs, tests, or examples, rerun the affected validation and keep `auto-review` in the loop until the final diff has been reviewed.
   - Do not spend time on style while correctness, failure modes, security, data integrity, or maintainability concerns remain.
   - Stop for guidance if review feedback conflicts, requires a product decision, or cannot be defended from the code.

6. Update the plan and finish the slice.
   - Update the plan's progress, validation notes, decisions, or next-slice sequencing when the implementation changes them, but do this before the final `auto-review` pass when possible.
   - If a plan update is made after `auto-review` reports ready, rerun relevant validation and `auto-review` before committing.
   - Review the final diff and keep only files belonging to the slice.
   - When commits are expected, stage only the slice, follow repository git identity, signing, and commit-message instructions, and use the repository's message convention.

7. Continue or stop.
   - If the user requested a specific slice or slice set, stop when that target is complete and committed when required.
   - If the user requested general plan execution, return to step 2 for the next incomplete slice.
   - Stop when no actionable slices remain, validation or `auto-review` is blocked, the next slice needs user judgment, or continuing would broaden beyond the plan.

8. Optional PR publication.
   - Publish or update a PR only when the user asks for a PR, a push, review prep, or work on an existing PR.
   - Push the branch and create or update a non-draft PR unless the user says the work is still in progress.
   - Use `writing-pr-descriptions` against the final branch, plan context, and applicable repository template to draft or update the title and body before publication.

9. Optional PR babysitting.
   - Use `babysitting-prs` only when the user asks to babysit, make merge-ready, fix PR feedback, watch CI, land, merge, or otherwise drive the PR after publication.
   - Do not introduce Codex PR review into the workflow unless the user asks for it or Codex is already part of that PR's review process.
   - If checks fail during requested PR babysitting, inspect the failing jobs, fix the cause, push, and repeat the check loop.
   - Use a bounded loop. Stop and ask for guidance if PR feedback conflicts, requires a product decision, or cannot be defended from the code.

10. Report or demonstrate the result.
   - Give a concise final handoff covering completed slices, validation, plan updates, and any blocker or next action.
   - Use `work-walkthrough` only when the user explicitly requested a demo, walkthrough, showcase, or substantial handoff.

## Definition of Done

The default local workflow is done only when:

- The target slice set, or the current executable plan segment, is implemented and validated.
- The plan reflects any material scope, validation, or progress changes.
- `auto-review` reports ready, or any remaining blocker is concrete and reported.
- Each completed slice has a clear boundary and is committed locally when the repository or user expects slice commits.

If the user asked for PR publication, the PR must be open or updated and `writing-pr-descriptions` must report its metadata current at the final published head.

If the user asked for PR babysitting, the PR must have passing checks and no pending or actionable review feedback unless a concrete blocker remains.

Do not push, publish a PR, request PR review, babysit, merge, or land unless the user explicitly asks.

## Final Response

Report:

- Branch and commit(s), when commits were requested or required.
- Slice(s) implemented.
- Validation run and results.
- `auto-review` status and any fixes made from it.
- Plan updates made.
- PR, CI, and review state only when PR publication or babysitting was requested.
- Any remaining risks or follow-up slices.
- A `work-walkthrough` only when the user requested one.

If the stop condition could not be reached, explain the blocker with concrete evidence and the next action.
