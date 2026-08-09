---
name: handling-codex-reviews
description: Handles Codex GitHub PR review loops by waiting for reviews, fixing actionable feedback, resolving threads, and requiring Codex's main-thread thumbs-up. Use when Codex is already reviewing a PR, the PR has `@codex review` activity, or Codex has added an `eyes` reaction.
---

# Handling Codex Reviews

Drive an existing or explicitly requested Codex review loop to completion. Do not introduce Codex merely because this skill is available.

Inspecting state is read-only. Fixing code, pushing, replying, reacting, resolving threads, or posting `@codex review` must be within the user’s requested PR workflow.

## Shared Helper

Load `babysitting-prs` and use its `scripts/pr_babysit.sh` helper. It is the single implementation for generic PR state and Codex state:

```bash
scripts/pr_babysit.sh codex-state --pr 32 --repo owner/repo
scripts/pr_babysit.sh codex-wait --pr 32 --repo owner/repo --timeout 900 --interval 20
scripts/pr_babysit.sh resolve --pr 32 --repo owner/repo --comment-ids 12345,67890
scripts/pr_babysit.sh checks --pr 32 --repo owner/repo
```

Run those commands from the loaded `babysitting-prs` skill directory.

## Workflow

1. Inspect Codex state and verify the actual review author from current PR activity; bot identities vary.
2. If `pending_review=true`, wait. A clean pass may end with a 👍 reaction rather than a review comment.
3. Classify feedback as actionable, already addressed, inaccurate, or requiring user judgement. Batch grounded fixes across inline comments and actionable top-level reviews.
4. Validate, commit, and push before replying.
5. Reply inline with `Fixed in <sha>: <what changed>`. For top-level reviews, post `Fixed in <sha> for review <review-id>: <what changed>`.
6. React only when the reaction accurately acknowledges the feedback. Resolve threads only after the fix and reply are visible.
7. If the user explicitly requested a first Codex review and `codex_review_required=false`, post one initial trigger. Otherwise, when Codex is already required but has not approved the current head, post exactly one fresh trigger:
   ```text
   @codex review

   Head: <40-character-head-sha>
   ```
8. Repeat until no review is pending, no actionable Codex feedback remains, checks pass, and `main_thread_approved=true`.

## Safety Rules

- Never use `@codex` in routine fix replies; anything other than `@codex review` can start a noisy cloud task.
- Do not amend commits after replies cite their SHA.
- If `codex_review_unavailable=true`, do not wait or post another trigger.
- Use a bounded loop. Stop for conflicting feedback, user judgement, unavailable permissions, or repeated failure.
