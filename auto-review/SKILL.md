---
name: auto-review
description: Iteratively reviews and improves the current PR or branch by running general-code-reviewing, fixing grounded issues, validating, and re-reviewing until the change is merge-ready or blocked. Use when asked to auto-review, self-review and fix, harden, polish, or get a PR ready.
---

# Auto review

Run a review, fix what it finds, validate, and re-check until the change is ready or blocked. `general-code-reviewing` is the review engine. This skill owns the loop, the fixes, and the validation.

## Rules

- The target is the current PR or branch diff unless the user names another PR, range, or file set.
- Review passes are read-only. Edit only after synthesizing findings and deciding which fixes have evidence and are in scope.
- Check `git status` before editing. Do not revert or absorb unrelated changes.
- Do not spawn sub-agents unless the user asks for them.
- Do not introduce GitHub Codex review. If the PR already has an `@codex review` comment or a Codex `eyes` reaction, use `handling-codex-reviews` alongside the local passes.
- Commit, push, reply, and merge only under the rules in `babysitting-prs`.

## Find the target

Read `AGENTS.md`, `git status`, the branch, remotes, and PR metadata. Take the base SHA from the PR host when there is a PR; otherwise use the merge-base with `origin/<default-branch>`. Keep that base for the whole loop. Read the diff, the changed tests, and the call sites around them. Record pre-existing dirty files so your changes stay separate. If the target is unclear, ask one question.

## Loop

At most two full review passes, and at most two fix-and-recheck rounds inside each.

1. Full review with `general-code-reviewing`. Keep the findings, verdict, and checked and deferred areas.
2. Triage. Fix critical, high, and medium findings that have evidence, are reachable, and are in scope. Fix low findings only when cheap. Defer the rest with the reason.
3. Patch narrowly, following repository patterns. Prefer deleting to adding.
4. Validate with the smallest meaningful tests or lints first, then the repository's broader checks. Use project commands (`mise`, package scripts, language tooling) before inventing new ones.
5. Recheck the fixes, the original findings, and the affected call sites and tests with the relevant lens. Passing tests are not a recheck. If a fix changed the shape of the diff, widen the recheck to match.
6. Repeat the fix-and-recheck round once when real findings remain.
7. Run the second full pass only when fixes changed the structure or behavior of the diff, the recheck exposed cross-cutting risk, or findings remain after the first pass.

After the last edit, run `writing-pr-descriptions` against the final diff when the target is a PR. Load `check-docs-updated` when the diff changes behavior, commands, config, APIs, plans, examples, or runbooks; otherwise say in a sentence why docs are not needed.

## Stop states

`ready` when the last review and recheck have no findings, validation passes or any skip is justified, PR text and docs are current, and the final diff was reviewed after the last edit.

`needs-attention` when fixable findings remain but the pass or round limit is reached. Name them.

`blocked` when the same finding survives two real fix attempts, validation fails for a cause outside the change, the target or base or auth is unavailable, or a fix needs a product, security, migration, or rollout decision the user has not made.

Check for `blocked` first, then `needs-attention`, then `ready`.

## Output

Write per `writing-plainly`. Start with `Status: ready | needs-attention | blocked`, then a short paragraph for each of these that has content: what the passes found and what was fixed, the validation commands and results, residual risk or deferred items, and branch, commit, and PR details when something was committed or pushed.
