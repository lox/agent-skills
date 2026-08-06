---
name: addressing-pr-reviews
description: Responds to PR review comments. Use when addressing reviewer feedback, replying to diff comments, or checking for unaddressed reviews.
---

# Addressing PR Reviews

Reply to PR review comments from human reviewers or automated bots.

Checking comments is read-only. A request to address review feedback authorizes the necessary in-scope code changes and review replies, but commit, push, reaction, resolution, reviewer-request, and `@codex review` actions must also be part of the requested PR workflow. Re-fetch review state after remote writes.

## Check for Review Comments

```bash
# List diff comments (inline on code)
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  --paginate \
  --jq '.[] | {id, user: .user.login, path, line, body: .body[0:100]}'

# Get full diff comment body
gh api repos/{owner}/{repo}/pulls/comments/{comment_id} --jq '.body'

# List top-level review comments (not on specific lines)
gh api repos/{owner}/{repo}/pulls/{pr}/reviews \
  --paginate \
  --jq '.[] | select(.body != "") | {id, user: .user.login, state, body: .body[0:200]}'

# Get full review body
gh api repos/{owner}/{repo}/pulls/{pr}/reviews/{review_id} --jq '.body'
```

## Reply to Diff Comments

When replying to a diff comment, reply inline to the specific comment unless the thread is already resolved or outdated.

For all reviewers (human or bot), use a normal inline reply without `@codex`:
```bash
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  -f body="Fixed in {commit}: {explanation}" \
  -F in_reply_to={comment_id}
```

Do not mention `@codex` in routine replies. Request Codex only when current PR activity proves Codex is already participating in that PR.

## Reply to Top-Level Reviews

For top-level review comments (not on specific lines), use a normal PR comment:

```bash
gh pr comment {pr} --body "Fixed in {commit}: {explanation}"
```

## Add Reactions

Acknowledge valid feedback with a thumbs up:

```bash
gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions \
  -f content="+1"
```

For inaccurate Codex feedback, use thumbs down:

```bash
gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions \
  -f content="-1"
```

## Request Re-review

Re-request the reviewer already participating in the PR. Inspect current review requests, reviews, comments, checks, and reactions before choosing the mechanism; do not introduce a different review bot.

For human reviewers:
```bash
gh pr edit {pr} --add-reviewer {username}
```

For an automated reviewer other than Codex, use that bot's established re-review mechanism from the current PR or repository configuration. Reply to or mention that bot when its integration expects a comment; use its check or app control when that is the established mechanism. Do not substitute Codex merely because its command is known.

For Codex, first verify that the PR already contains Codex-authored review activity, a prior `@codex review` request, or a Codex reaction. Only then trigger exactly one review request after batching fixes:
```bash
gh pr comment {pr} --body "@codex review"
```

If no reviewer is already participating, do not introduce a review bot unless a separate workflow explicitly owns reviewer selection. Reviewer account names and invocation mechanisms vary by setup; discover them from current PR and repository evidence rather than hard-coding a bot username.

## Known Failure Mode (Codex Task-Mode Noise)

Codex GitHub behaviour is:
- `@codex review` requests a review run.
- `@codex` with anything else starts a Codex cloud task.

Do not post routine fix replies like:

```text
@codex Fixed in {commit}: {explanation}
```

That can create noisy task-output comments (for example, "Summary", "committed on branch", "opened follow-up PR") that do not reflect actual repo state.

Use this instead for routine updates:

```text
Fixed in {commit}: {explanation}
```

Then, only when Codex was already participating, post exactly one after batching fixes:

```text
@codex review
```

## Workflow

1. **Check comments**: List unaddressed review comments
2. **Fix each issue**: Make code changes
3. **Commit & push**: Include the fix
4. **Reply inline**: Reference the commit hash in your reply
5. **React**: Add 👍 to acknowledge the feedback
6. **Request re-review**: Re-engage the human or bot already participating, using that reviewer's established mechanism
7. **Keep Codex conditional**: Post one `@codex review` only when Codex was already part of the PR
8. **Avoid task-mode noise**: Never use `@codex` in routine "fixed" replies

**Important**: Don't amend commits after replying - the referenced commit hash becomes invalid.
