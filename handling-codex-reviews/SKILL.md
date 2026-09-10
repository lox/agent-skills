---
name: handling-codex-reviews
description: Handles Codex GitHub PR review loops by waiting for reviews, fixing actionable feedback, resolving threads, and requiring Codex's main-thread thumbs-up. Use when Codex is already reviewing a PR, the PR has `@codex review` activity, or Codex has added an `eyes` reaction.
---

# Handling Codex reviews

Finish a Codex review loop that already exists or that the user asked for. Do not start one because this skill is available.

Reading state is always allowed. Fixing, pushing, replying, reacting, resolving threads, and posting `@codex review` must be part of the PR workflow the user requested.

## Helper

Load `babysitting-prs` and run its `scripts/pr_babysit.sh` from that skill's directory. It is the one implementation of PR and Codex state.

```bash
scripts/pr_babysit.sh codex-state --pr 32 --repo owner/repo
scripts/pr_babysit.sh codex-wait --pr 32 --repo owner/repo --timeout 900 --interval 20
scripts/pr_babysit.sh resolve --pr 32 --repo owner/repo --comment-ids 12345,67890
scripts/pr_babysit.sh checks --pr 32 --repo owner/repo
```

## Workflow

1. Read Codex state and confirm who actually authored the review from PR activity; bot identities vary.
2. If `pending_review=true`, wait. A clean pass may end in a 👍 reaction with no comment.
3. Sort feedback into actionable, already addressed, inaccurate, or needing the user. Batch the actionable fixes across inline comments and top-level reviews.
4. Validate, commit, and push before replying.
5. Reply inline with `Fixed in <sha>: <what changed>`; for a top-level review, `Fixed in <sha> for review <review-id>: <what changed>`. One or two sentences per `writing-plainly`. When declining, give the evidence, with no thanks or apology.
6. React only when the reaction is accurate. Resolve a thread only after the fix and reply are visible.
7. If the user asked for a first Codex review and `codex_review_required=false`, post one trigger. If Codex is required but has not approved the current head, post exactly one fresh trigger:
   ```text
   @codex review

   Head: <40-character-head-sha>
   ```
8. Repeat until no review is pending, no actionable feedback remains, checks pass, and `main_thread_approved=true`.

## Safety

- Never write `@codex` in a routine reply. Anything other than `@codex review` can start a cloud task.
- Never amend a commit after a reply cites its SHA.
- If `codex_review_unavailable=true`, do not wait or post another trigger.
- Stop for conflicting feedback, a call that needs the user, missing permissions, or a failure that repeats.
