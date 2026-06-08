---
name: handling-codex-reviews
description: Handles Codex GitHub PR review loops by waiting for reviews, fixing actionable feedback, resolving threads, and requiring Codex's main-thread thumbs-up. Use when Codex is a reviewer or a PR has `@codex review` activity.
---

# Handling Codex Reviews

Drive the Codex-specific review loop for a GitHub pull request.

## Use this when

- A PR has `@codex review` activity.
- Codex has left inline diff comments or top-level review feedback.
- Another skill, such as `babysitting-prs`, detects Codex as a reviewer and needs the Codex loop completed.

## Core workflow

1. Resolve PR context (`owner/repo`, PR number, branch).
2. Run `scripts/codex_review_loop.sh state --pr <pr> --repo <owner/repo>`.
3. If `pending_review=true`, run `scripts/codex_review_loop.sh wait --pr <pr> --repo <owner/repo>`.
4. Fix all actionable Codex feedback in one batch:
   - inline diff comments from `actionable_diff_comments`
   - actionable top-level review bodies from `actionable_top_level_reviews`
5. Run relevant tests.
6. Commit and push.
7. Reply to each addressed inline diff comment with `Fixed in <sha>: <what changed>`.
8. For top-level review feedback, post a normal PR comment that includes the Codex review ID: `Fixed in <sha> for review <review-id>: <what changed>`.
9. Add 👍 reactions to addressed Codex comments.
10. Resolve addressed review threads: `scripts/codex_review_loop.sh resolve --pr <pr> --repo <owner/repo> --comment-ids <id1,id2,...>`.
11. Check CI status: `scripts/codex_review_loop.sh checks --pr <pr> --repo <owner/repo>`.
12. If there is no review in progress and Codex has not approved the latest trigger, post exactly one fresh `@codex review`.
13. Repeat until no pending review, no actionable Codex feedback, checks pass, and the latest `@codex review` comment has a 👍 reaction from Codex.

## Important rules

- Never use `@codex` in routine "fixed" replies.
- Only `@codex review` should be used to request a new review pass.
- Do not consider Codex complete until `main_thread_approved=true`.
- Use a bounded loop. Stop and ask for guidance if feedback is conflicting, unclear, or requires product judgement.
- Do not amend commits after posting `Fixed in <sha>` replies.
- Always resolve conversations after addressing feedback and replying.

## Commands

```bash
# Show Codex state for a PR
~/.config/agents/skills/handling-codex-reviews/scripts/codex_review_loop.sh state --pr 32 --repo owner/repo

# Wait for pending Codex review to finish
~/.config/agents/skills/handling-codex-reviews/scripts/codex_review_loop.sh wait --pr 32 --repo owner/repo --timeout 900 --interval 20

# Resolve review threads for addressed comments
~/.config/agents/skills/handling-codex-reviews/scripts/codex_review_loop.sh resolve --pr 32 --repo owner/repo --comment-ids 12345,67890

# Check PR CI status from GitHub's check rollup
~/.config/agents/skills/handling-codex-reviews/scripts/codex_review_loop.sh checks --pr 32 --repo owner/repo

# Auto-detect PR from current branch
~/.config/agents/skills/handling-codex-reviews/scripts/codex_review_loop.sh state
```

## State interpretation

- `pending_review=true`: a recent `@codex review` trigger exists without newer Codex activity.
- `actionable_diff_comments_count>0`: unresolved Codex inline diff comments need fixes or explicit replies.
- `actionable_top_level_reviews_count>0`: actionable Codex top-level review feedback needs fixes or an explicit PR comment that references the review ID.
- `main_thread_approved=false`: Codex has participated, but the latest `@codex review` trigger has not received Codex's 👍 for the current head commit.
- `ready_for_codex=true`: Codex has no pending review or actionable feedback and has approved the latest review trigger when required.

## Reply templates

```text
Fixed in <sha>: <concise summary of change>
```

```text
Fixed in <sha> for review <review-id>: <concise summary of change>
```

```text
@codex review
```
