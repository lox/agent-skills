---
name: addressing-pr-reviews
description: Responds to PR review comments. Use when addressing reviewer feedback, replying to diff comments, or checking for unaddressed reviews.
---

# Addressing PR Reviews

Reply to PR review comments from human reviewers or automated bots.

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

Always reply inline to the specific comment.

For all reviewers (human or bot), use a normal inline reply without `@codex`:
```bash
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  -f body="Fixed in {commit}: {explanation}" \
  -F in_reply_to={comment_id}
```

Use `@codex` only when you explicitly want to trigger a Codex action.

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

For human reviewers:
```bash
gh pr edit {pr} --add-reviewer {username}
```

For Codex, trigger exactly one explicit review request after batching fixes:
```bash
gh pr comment {pr} --body "@codex review"
```

Note: reviewer account names can vary by setup; do not hard-code a single bot username.

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

Then, after batching fixes, post exactly one:

```text
@codex review
```

## Workflow

1. **Check comments**: List unaddressed review comments
2. **Fix each issue**: Make code changes
3. **Commit & push**: Include the fix
4. **Reply inline**: Reference the commit hash in your reply
5. **React**: Add 👍 to acknowledge the feedback
6. **Request re-review**: Add reviewer back or post a single `@codex review`
7. **Avoid task-mode noise**: Never use `@codex` in routine "fixed" replies

**Important**: Don't amend commits after replying - the referenced commit hash becomes invalid.
