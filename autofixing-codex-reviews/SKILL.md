---
name: autofixing-codex-reviews
description: Automates a Codex PR review loop by detecting pending Codex reviews, identifying unaddressed Codex feedback, and driving fix-and-reply iterations until merge-ready. Use when asked to auto-fix PR review feedback from Codex.
---

# Autofixing Codex Reviews

Runs a robust review-fix loop for Codex feedback on a GitHub pull request.

## Use this when

- The user asks to auto-fix Codex PR feedback.
- A PR has `@codex review` activity and may still be pending.
- A PR has unaddressed Codex inline comments that need code changes and replies.

## Core workflow

1. Resolve PR context (`owner/repo`, PR number, branch).
2. Run `scripts/codex_review_loop.sh state --pr <pr>` to classify state.
3. If `pending_review=true`, run `scripts/codex_review_loop.sh wait --pr <pr>`.
4. If actionable comments exist, fix all actionable items in one batch.
5. Run relevant tests.
6. Commit and push.
7. Reply inline to each addressed diff comment with `Fixed in <sha>: <what changed>`.
8. Add 👍 reactions to addressed comments.
9. Resolve addressed review threads: `scripts/codex_review_loop.sh resolve --pr <pr> --comment-ids <id1,id2,...>`.
10. Check CI status: `scripts/codex_review_loop.sh checks --pr <pr>`.
    - If checks are failing, investigate the failures, fix, and push again.
    - If checks are pending, wait and re-check.
11. Trigger one fresh review with `@codex review` only after all fixes are pushed and checks pass.
12. Repeat until no pending review, no actionable Codex feedback, and checks pass.

## Important rules

- Never use `@codex` in routine "fixed" replies.
- Use a bounded loop (recommended max: 3 iterations).
- Stop and ask for human guidance if feedback is conflicting or unclear.
- Do not amend commits after posting `Fixed in <sha>` replies.
- Always resolve conversations after addressing feedback and replying.
- Always verify CI checks pass before triggering a new review cycle.

## Commands

```bash
# Show full state summary for a PR
~/.config/agents/skills/autofixing-codex-reviews/scripts/codex_review_loop.sh state --pr 32

# Wait for pending Codex review to finish (or timeout)
~/.config/agents/skills/autofixing-codex-reviews/scripts/codex_review_loop.sh wait --pr 32 --timeout 900 --interval 20

# Resolve review threads for addressed comments
~/.config/agents/skills/autofixing-codex-reviews/scripts/codex_review_loop.sh resolve --pr 32 --comment-ids 12345,67890

# Check CI status for the PR
~/.config/agents/skills/autofixing-codex-reviews/scripts/codex_review_loop.sh checks --pr 32

# Auto-detect PR from current branch
~/.config/agents/skills/autofixing-codex-reviews/scripts/codex_review_loop.sh state
```

## State interpretation

- `pending_review=true`: a recent `@codex review` trigger exists without newer Codex activity.
- `actionable_diff_comments_count>0`: unresolved Codex inline diff comments exist.
- `ready_for_merge=true`: no pending review and no unresolved Codex diff comments.

## Checks interpretation

- `all_passed=true`: all CI checks have succeeded.
- `any_failed=true`: one or more checks failed — investigate and fix.
- `any_pending=true`: checks are still running — wait and re-check.

## Reply templates

```text
Fixed in <sha>: <concise summary of change>
```

```text
@codex review
```
