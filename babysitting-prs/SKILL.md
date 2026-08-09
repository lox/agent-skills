---
name: babysitting-prs
description: Babysits GitHub pull requests through review feedback, rebases, CI or Buildkite failures, Codex review when already active, and optional merge. Use when asked to babysit a PR, fix PR feedback, make a PR mergeable, or get it merged.
---

# Babysitting PRs

Drive a GitHub pull request from its current state to merged, handling reviewers, Codex, stale branches, and CI along the way.

## Use this when

- The user asks to babysit, shepherd, land, or merge a PR.
- A PR needs review feedback fixed, whether from Codex, another bot, or a human reviewer.
- A PR is blocked on failing checks, Buildkite failures, merge conflicts, stale base branch, or merge queue state.
- Another workflow asks you to keep a PR green and mergeable. In that case, obey any explicit "do not merge" instruction from that workflow.

## Requirements

The helper requires `gh` and `jq`, plus authenticated GitHub access:

```bash
command -v gh jq
gh auth status
```

Use GitHub's check rollup first. Only require `bk` authentication when the PR actually has Buildkite checks and linked GitHub output is insufficient for the diagnosis or control the task needs. If so, verify `command -v bk` and `bk auth status` before using Buildkite-specific logs, artefacts, retries, or controls. Missing Buildkite access blocks only that diagnosis, not review triage or unrelated PR work.

## Companion skills to load as needed

- `addressing-pr-reviews`: use for collecting review comments, replying inline, reacting, requesting re-review, and avoiding Codex task-mode noise.
- `handling-codex-reviews`: use when the PR is already in a Codex flow: `codex.codex_review_required=true`, pending review, actionable feedback, or Codex `eyes`. Delegate Codex-specific waiting, fixes, replies, thread resolution, fresh triggers, and thumbs-up approval.
- `adversarial-code-reviewing`: use before pushing non-trivial code fixes, especially after rebases or CI-driven changes.
- `writing-pr-descriptions`: use after material code changes to keep the title, body, and UI screenshots aligned with the final head.

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
   - If status reports `codex.codex_review_unavailable=true`, continue with non-Codex blockers; do not post `@codex review` or wait unless the user asks to set up Codex.
   - If status reports `codex.codex_review_required=true`, `codex.pending_review=true`, actionable Codex feedback, `codex_thumbs_up_missing`, or active Codex `eyes`, use `handling-codex-reviews`.
   - Treat Codex as incomplete until there is no pending review, no actionable feedback, and `main_thread_approved=true`.
   - Do not introduce Codex to a PR that is not already using it.

5. **Clear CI and Buildkite blockers**
   - Run `scripts/pr_babysit.sh checks --pr <pr> --repo <owner/repo>` and inspect failures.
   - For Buildkite checks, inspect GitHub's linked details first. If more detail or control is needed, use available Buildkite tools or `bk` after verifying its authentication.
   - If a failure is caused by the branch, fix it, run the narrowest relevant local validation, commit, push, and re-check.
   - If a failure is flaky or external, retry the failed job/build once and record the evidence.
   - Do not mark a PR ready because GitHub checks are green if Buildkite is still failed, blocked, or pending.

6. **Merge or hand off**
   - Merge only when the user explicitly asks to merge, land, ship, queue, or get the PR merged.
   - If the user asks for mergeable, green, or ready-for-review state, stop once the PR is merge-ready and report the handoff.
   - If the user only says to babysit a PR without a merge verb, keep the PR merge-ready and ask before the final merge.
   - If this workflow materially changed code, behavior, scope, evidence, or the base-to-head diff, run `writing-pr-descriptions` against the final head before declaring the PR ready.
   - Before merging, verify: PR is open and not draft, no unresolved actionable threads, no pending/actionable Codex work when Codex is in use, required reviews are satisfied, checks are green, and GitHub reports mergeable.
   - Immediately before merging, re-fetch the PR head SHA and check state. Merge only if they still match the reviewed, green head.
   - Use the repo's expected merge path: merge queue when required, auto-merge when branch protection is waiting, otherwise the repo's normal squash/merge/rebase method.
   - Delete the branch only when the user requested it or repository configuration makes deletion the established merge behavior.

## Commands

```bash
# Full PR state summary: run from the loaded skill directory
scripts/pr_babysit.sh status --pr 32 --repo owner/repo

# Resolve review threads for addressed diff comments
scripts/pr_babysit.sh resolve --pr 32 --repo owner/repo --comment-ids 12345,67890

# Check PR CI status from GitHub's check rollup
scripts/pr_babysit.sh checks --pr 32 --repo owner/repo

# Auto-detect PR from the current branch
scripts/pr_babysit.sh status
```

## State interpretation

- `ready_to_merge=true`: the helper found no obvious local blockers. Still apply judgement before merging.
- `merge_blockers`: concrete blockers to clear before merge.
- `checks.any_failed=true`: investigate and fix or retry failed checks.
- `checks.any_pending=true`: wait and re-check.
- `codex.codex_review_required=true`: this PR is already using Codex; use `handling-codex-reviews`.
- `codex.codex_review_unavailable=true`: Codex review is not enabled; do not post `@codex review` or block on a Codex thumbs-up.
- `codex.pending_review=true`: wait for Codex before acting on its feedback.
- `codex.has_codex_eyes=true`: Codex has an in-progress `eyes` reaction; use `handling-codex-reviews`.
- `codex.actionable_diff_comments_count>0`: unresolved Codex inline comments need fixes or explicit replies.
- `codex.actionable_top_level_reviews_count>0`: actionable Codex top-level review feedback needs fixes or explicit replies.
- `codex.main_thread_approved=false`: when Codex is required, use `handling-codex-reviews`.

## Reply templates

```text
Fixed in <sha>: <concise summary of change>
```

For Codex top-level replies or fresh `@codex review` triggers, use `handling-codex-reviews`. Do not post `@codex review` unless Codex is already in the PR flow or the user asks for it.

## Stop conditions

Stop and report the exact blocker only when:

- Required GitHub access is unavailable, or Buildkite access is unavailable when Buildkite-only diagnostics are necessary.
- Required human approval, security sign-off, product judgement, or credentials are unavailable.
- Merge permissions or branch protection prevent you from queueing, auto-merging, or merging.
- The same CI failure persists after two evidence-based fix attempts or one justified flaky retry.
- Review feedback is contradictory or impossible to satisfy without changing the intended scope.
