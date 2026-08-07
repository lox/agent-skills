---
name: auto-review
description: Iteratively reviews and improves the current PR or branch by running general-code-reviewing, fixing grounded issues, validating, and re-reviewing until the change is merge-ready or blocked. Use when asked to auto-review, self-review and fix, harden, polish, or get a PR ready.
---

# Auto Review

Drive a review-fix-validation loop for a current PR or branch. Use `general-code-reviewing` as the review engine; unlike a normal review, act on grounded ship-risk and simplicity findings and re-check fixes until confidence is high.

## Review Engine

- Load and use `general-code-reviewing` for each full review pass. Let that skill run its ship-risk and simplicity lenses; `auto-review` owns the bounded outer loop, fixes, validation, and targeted rechecks.

Keep final-readiness checks lazy:

- For a PR, compare its title and body with the final diff. Load `check-pr-description` only when metadata may be stale, needs editing, or requires a deeper convention check.
- Inspect whether the final diff changes durable behavior, commands, configuration, APIs, plans, examples, or runbooks. Load `check-docs-updated` only when relevant documentation may exist or drift is plausible. Otherwise state briefly why docs are not required.

## Operating Contract

- Treat the current PR or branch diff as the target unless the user names a different PR, commit range, or file set.
- Preserve caller, platform, or connector-required output formats. If a caller requires structured review output, adapt the loop summary to that format.
- Do not spawn sub-agents unless the user explicitly asks for sub-agents, parallel agents, delegated review, or parallel review work. When reviewing, follow `general-code-reviewing`'s delegation rules.
- Keep review passes read-only. Make edits only after synthesizing findings and deciding which fixes are grounded and in scope.
- Respect user work: inspect `git status` before editing, do not revert unrelated changes, and do not absorb unrelated dirty files into commits.
- Do not claim high confidence while validation is failing or material findings remain unresolved.

## GitHub Codex Review Boundary

- Perform review passes locally through `general-code-reviewing` and the other companion skills.
- Do not post an initial `@codex review` comment or otherwise introduce GitHub Codex review to a PR.
- Continue an existing GitHub Codex review loop only when the PR already has an `@codex review` comment or a Codex-authored `eyes` reaction. In that case, use `handling-codex-reviews` for the existing external loop without replacing the required local review passes.

## Target Discovery

1. Read repository instructions and current state: `AGENTS.md`, `git status`, branch name, remotes, and existing PR metadata when available.
2. Identify a fresh base revision. When reviewing a PR, use the PR base SHA from the host, not a possibly stale local branch. Otherwise fetch remote metadata and use the merge-base with `origin/<default-branch>` or the tracked upstream branch. Keep the same base through the loop unless the PR base changes.
3. Inspect the diff plus changed tests and surrounding call sites. If the target cannot be identified, ask one concise question.
4. Record pre-existing dirty files before editing so the loop can keep its own changes separate.

## Review-Fix Loop

Use at most two full review passes. Within each full pass, use at most two fix-and-targeted-recheck rounds.

1. Full review: run `general-code-reviewing` over the exact target. Capture ship-risk and simplicity findings, checked areas, deferred areas, and verdict.
2. Triage: convert findings into actions. Fix critical, high, and medium findings that are grounded, reachable, and in scope. Fix low findings only when they are cheap or clearly quality-relevant. Defer out-of-scope, pre-existing, or speculative concerns with evidence.
3. Patch: make narrow edits following repository patterns. Prefer deleting or simplifying code over adding layers.
4. Validate: run the smallest meaningful tests or lints first, then broader repo validation as needed. Use local project commands such as `mise`, package scripts, and language tooling before inventing new commands.
5. Targeted recheck: review the fixes, original findings, affected call sites, tests, and likely blast radius with the relevant review lenses. Do not rerun the entire broad review merely because the diff changed.
6. Repeat the fix and targeted-recheck round once when material findings remain and another focused fix is justified.
7. Run a second full review only when the fixes materially changed the structure or behavior of the diff, the targeted recheck exposed cross-cutting risk, or material findings remain after the first pass's rounds.

Each recheck must be fresh and read-only. Passing tests alone is not a recheck. If a fix changes the shape of the diff, expand the recheck to affected call sites and tests rather than assuming prior coverage still applies.

## Stop Conditions

Stop with `ready` only when all are true:

- the latest applicable full review and targeted recheck have no material findings after synthesis;
- relevant validation passes, or any skipped validation is explicitly justified;
- no unresolved critical, high, or medium findings remain;
- PR title/body are current when the target is a PR;
- relevant docs/plans are current or explicitly not required;
- low-risk follow-ups are either fixed or clearly documented as non-blocking;
- the final diff has been reviewed after the last edit.

Stop with `needs-attention` when fixable material findings remain but the user-set budget, review budget, or loop limit prevents another useful iteration. Report exactly which findings remain actionable.

Stop with `blocked` when:

- the same finding recurs after two serious fix attempts;
- validation fails for a cause outside the current change and cannot be isolated;
- target, base, or auth information is unavailable;
- a fix requires product, security, migration, or rollout decisions the user has not supplied.

Apply stop states in this order: `blocked`, then `needs-attention`, then `ready`. A partial approval cannot override a blocker, and reaching the two-pass or per-pass round cap with material findings remaining is `needs-attention`.

## Git and PR Handling

- Commit and push only when the user asked to update a PR, prepare it for review, or otherwise carry the branch forward. Follow repository commit and signing instructions.
- Stage only files changed for this loop.
- If pushing, use the current PR branch and avoid rewriting history unless the user requested it or repository policy permits it.
- Do not merge a PR unless the user explicitly asks to merge, land, ship, or queue it.
- If PR review comments or CI are involved, use the repository's existing PR or CI workflow skills rather than duplicating them. Use `handling-codex-reviews` only within the GitHub Codex review boundary above.

## Output

Final response:

1. State `Status: ready | needs-attention | blocked`.
2. Summarize review iterations and fixes briefly.
3. List validation commands and results.
4. Call out residual risks or deferred items.
5. Include branch, commit, and PR details when commits or pushes were made.
