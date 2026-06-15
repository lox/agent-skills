---
name: auto-review
description: Iteratively review and improve the current PR or branch by running general-code-reviewing, fixing grounded issues, validating, and re-reviewing until the change is merge-ready or a blocker remains. Use when asked to auto-review, self-review and fix, harden, polish, get a PR ready, or iterate on code quality rather than only return review comments.
---

# Auto Review

Drive a review-fix-validation loop for a current PR or branch. Use `general-code-reviewing` as the review engine; unlike a normal review, act on grounded findings and re-run the review after fixes until confidence is high.

## Operating Contract

- Treat the current PR or branch diff as the target unless the user names a different PR, commit range, or file set.
- Preserve caller, platform, or connector-required output formats. If a caller requires structured review output, adapt the loop summary to that format.
- Do not spawn sub-agents unless the user explicitly asks for sub-agents, parallel agents, delegated review, or parallel review work. When reviewing, follow `general-code-reviewing`'s delegation rules.
- Keep review passes read-only. Make edits only after synthesizing findings and deciding which fixes are grounded and in scope.
- Respect user work: inspect `git status` before editing, do not revert unrelated changes, and do not absorb unrelated dirty files into commits.
- Do not claim high confidence while validation is failing or material findings remain unresolved.

## Target Discovery

1. Read repository instructions and current state: `AGENTS.md`, `git status`, branch name, remotes, and existing PR metadata when available.
2. Identify the base revision from the PR base when reviewing a PR; otherwise use the upstream default branch or merge-base. Keep the same base through the loop unless the PR base changes.
3. Inspect the diff plus changed tests and surrounding call sites. If the target cannot be identified, ask one concise question.
4. Record pre-existing dirty files before editing so the loop can keep its own changes separate.

## Review-Fix Loop

Use this sequence:

1. Review: run `general-code-reviewing` over the exact target. Capture findings, checked areas, deferred areas, and verdict.
2. Triage: convert findings into actions. Fix critical, high, and medium findings that are grounded, reachable, and in scope. Fix low findings only when they are cheap or clearly quality-relevant. Defer out-of-scope, pre-existing, or speculative concerns with evidence.
3. Patch: make narrow edits following repository patterns. Prefer deleting or simplifying code over adding layers.
4. Validate: run the smallest meaningful tests or lints first, then broader repo validation as needed. Use local project commands such as `mise`, package scripts, and language tooling before inventing new commands.
5. Re-review: run `general-code-reviewing` again against the updated diff. Do not rely only on passing tests.
6. Repeat while material findings remain and fixes are making progress.

If a fix changes the shape of the diff, re-check affected call sites and tests instead of assuming prior review coverage still applies.

## Stop Conditions

Stop with `ready` only when all are true:

- the latest `general-code-reviewing` pass is `approve` or has no material findings after synthesis;
- relevant validation passes, or any skipped validation is explicitly justified;
- no unresolved critical, high, or medium findings remain;
- low-risk follow-ups are either fixed or clearly documented as non-blocking;
- the final diff has been reviewed after the last edit.

Stop with `needs-attention` when fixable material findings remain but the user-set budget, review budget, or loop limit prevents another useful iteration. Report exactly which findings remain actionable.

Stop with `blocked` when:

- the same finding recurs after two serious fix attempts;
- validation fails for a cause outside the current change and cannot be isolated;
- target, base, or auth information is unavailable;
- a fix requires product, security, migration, or rollout decisions the user has not supplied.

Avoid unbounded loops. After three full review-fix cycles, continue only if each cycle is still removing material risk; otherwise summarize the remaining blocker.

## Git and PR Handling

- Commit and push only when the user asked to update a PR, prepare it for review, or otherwise carry the branch forward. Follow repository commit and signing instructions.
- Stage only files changed for this loop.
- If pushing, use the current PR branch and avoid rewriting history unless the user requested it or repository policy permits it.
- If PR review comments or CI are involved, use the repository's existing PR, Codex-review, or CI workflow skills rather than duplicating them.

## Output

Final response:

1. State `Status: ready | needs-attention | blocked`.
2. Summarize review iterations and fixes briefly.
3. List validation commands and results.
4. Call out residual risks or deferred items.
5. Include branch, commit, and PR details when commits or pushes were made.
