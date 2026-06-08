---
name: babysitting-prs
description: Babysits GitHub pull requests through review comments, Codex feedback, rebases, Buildkite failures, merge queues, and final merge. Use when asked to babysit a PR, get a PR merged, fix PR feedback, or keep working until a PR is mergeable.
---

# Babysitting PRs

Drive a GitHub pull request from its current state to merged, handling reviewers, Codex, stale branches, and CI along the way.

## Use this when

- The user asks to babysit, shepherd, land, or merge a PR.
- A PR needs review feedback fixed, whether from Codex, another bot, or a human reviewer.
- A PR is blocked on failing checks, Buildkite failures, merge conflicts, stale base branch, or merge queue state.
- Another workflow asks you to keep a PR green and mergeable. In that case, obey any explicit "do not merge" instruction from that workflow.

## Required gate: Buildkite auth

Before doing PR work, verify both GitHub and Buildkite authentication.

```bash
gh auth status
bk auth status >/dev/null
```

If `bk auth status` fails, stop immediately and ask the user to run `bk auth login`. This is the hard blocker. Do not spend time triaging reviews, rebasing, or CI until Buildkite auth is available.

## Companion skills to load as needed

- `addressing-pr-reviews`: use for collecting review comments, replying inline, reacting, requesting re-review, and avoiding Codex task-mode noise.
- `adversarial-code-reviewing`: use before pushing non-trivial code fixes, especially after rebases or CI-driven changes.
- `humanizing-text`: use before posting substantial PR comments or human-facing status updates.
- `buildkite-preflight`: use when local changes should be validated against Buildkite before pushing, or when a repo's workflow expects preflight builds.
- `shipping-work`: use only if the user gave a branch without an existing PR and wants it opened before babysitting.

If a companion skill is unavailable, follow the same workflow manually and mention the missing skill only if it changes the outcome.

## Core loop

Use a bounded loop, usually three fix cycles. Each cycle should batch related fixes before pushing.

1. **Resolve context**
   - Identify `owner/repo`, PR number, branch, base branch, and whether the user expects final merge or only merge-ready state.
   - Check `git status`; preserve unrelated user or agent changes.
   - Run `scripts/pr_babysit.sh status --pr <pr> --repo <owner/repo>` for a quick PR state summary.

2. **Clear branch blockers**
   - If the branch is stale, conflicted, or behind a required base, rebase or merge the base branch using the repo's normal convention.
   - Resolve conflicts with the smallest correct change.
   - Run focused validation before pushing.

3. **Clear review blockers**
   - Gather unresolved review threads, latest reviews, and top-level comments.
   - For every actionable human or bot comment: fix the issue, commit, push, reply inline with `Fixed in <sha>: <what changed>`, add 👍, and resolve the thread when allowed.
   - If feedback is wrong, explain why briefly, add the appropriate reaction, and resolve only when it is clearly settled.
   - Stop for user guidance when feedback conflicts, requires product judgement, or cannot be defended from repo evidence.

4. **Handle Codex when present**
   - If a recent `@codex review` is pending, run `scripts/pr_babysit.sh codex-wait --pr <pr> --repo <owner/repo>`.
   - Fix actionable Codex inline comments in batches just like human review comments.
   - Never use `@codex` in routine "fixed" replies; that starts task-mode noise.
   - Trigger exactly one fresh `@codex review` only after fixes are pushed and checks are passing, and only when Codex is already part of this PR's review process or the user asks for it.

5. **Clear CI and Buildkite blockers**
   - Run `scripts/pr_babysit.sh checks --pr <pr> --repo <owner/repo>` and inspect failures.
   - For Buildkite checks, use Buildkite logs, annotations, failed jobs, and artefacts to find the real failure. Prefer Buildkite MCP tools when available; use `bk` or linked logs otherwise.
   - If a failure is caused by the branch, fix it, run the narrowest relevant local validation, commit, push, and re-check.
   - If a failure is flaky or external, retry the failed job/build once and record the evidence.
   - Do not mark a PR ready because GitHub checks are green if Buildkite is still failed, blocked, or pending.

6. **Merge or hand off**
   - Merge only when the user explicitly asks to merge, land, ship, queue, or get the PR merged.
   - If the user asks for mergeable, green, or ready-for-review state, stop once the PR is merge-ready and report the handoff.
   - If the user only says to babysit a PR without a merge verb, keep the PR merge-ready and ask before the final merge.
   - Before merging, verify: PR is open and not draft, no unresolved actionable threads, no pending Codex review, required reviews are satisfied, checks are green, and GitHub reports it as mergeable.
   - Use the repo's expected merge path: merge queue when required, auto-merge when branch protection is waiting, otherwise the repo's normal squash/merge/rebase method.
   - Delete the branch only when it is safe and conventional for the repo.

## Commands

```bash
# Full PR state summary, including Buildkite auth gate, checks, reviews, and Codex state
~/.config/agents/skills/babysitting-prs/scripts/pr_babysit.sh status --pr 32 --repo owner/repo

# Wait for a pending Codex review to finish
~/.config/agents/skills/babysitting-prs/scripts/pr_babysit.sh codex-wait --pr 32 --repo owner/repo --timeout 900 --interval 20

# Resolve review threads for addressed diff comments
~/.config/agents/skills/babysitting-prs/scripts/pr_babysit.sh resolve --pr 32 --repo owner/repo --comment-ids 12345,67890

# Check PR CI status from GitHub's check rollup
~/.config/agents/skills/babysitting-prs/scripts/pr_babysit.sh checks --pr 32 --repo owner/repo

# Auto-detect PR from the current branch
~/.config/agents/skills/babysitting-prs/scripts/pr_babysit.sh status
```

## State interpretation

- `ready_to_merge=true`: the helper found no obvious local blockers. Still apply judgement before merging.
- `merge_blockers`: concrete blockers to clear before merge.
- `checks.any_failed=true`: investigate and fix or retry failed checks.
- `checks.any_pending=true`: wait and re-check.
- `codex.pending_review=true`: wait for Codex before acting on its feedback.
- `codex.actionable_diff_comments_count>0`: unresolved Codex inline comments need fixes or explicit replies.

## Reply templates

```text
Fixed in <sha>: <concise summary of change>
```

```text
@codex review
```

Only use the second template for a fresh Codex review trigger, never for routine replies.

## Stop conditions

Stop and report the exact blocker only when:

- `bk auth status` fails.
- Required human approval, security sign-off, product judgement, or credentials are unavailable.
- Merge permissions or branch protection prevent you from queueing, auto-merging, or merging.
- The same CI failure persists after two evidence-based fix attempts or one justified flaky retry.
- Review feedback is contradictory or impossible to satisfy without changing the intended scope.
