---
name: addressing-pr-reviews
description: Responds to PR review comments. Use when addressing reviewer feedback, replying to diff comments, or checking for unaddressed reviews.
---

# Addressing PR Reviews

Reply to PR review comments from human reviewers or automated bots.

Checking comments is read-only. A request to address review feedback authorizes the necessary in-scope code changes and review replies, but commit, push, reaction, resolution, reviewer-request, and `@codex review` actions must also be part of the requested PR workflow. Re-fetch review state after remote writes.

## Build The Worklist

Use unresolved GitHub review threads as the source of truth for inline feedback. REST pull-request comments include replies and resolved conversations, so do not treat that endpoint as the worklist.

```bash
# List every unresolved review thread with full cursor pagination
gh api graphql \
  --paginate \
  -F owner='{owner}' \
  -F name='{repo}' \
  -F pr={pr} \
  -f query='
    query($owner: String!, $name: String!, $pr: Int!, $endCursor: String) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $pr) {
          reviewThreads(first: 100, after: $endCursor) {
            nodes {
              id
              isResolved
              isOutdated
              comments(first: 100) {
                nodes { databaseId author { login } body path line url }
              }
            }
            pageInfo { hasNextPage endCursor }
          }
        }
      }
    }' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)'
```

Use the first comment as the root finding and later comments as conversation context. An outdated thread may still describe a real issue, but verify it against the current diff before acting.

If the root author is Codex, hand the thread to `handling-codex-reviews`. Keep human and other-bot threads in this workflow, including mixed-reviewer PRs.

Top-level review bodies have no thread-resolution state. Exclude withdrawn or unsubmitted reviews and skip reviews already acknowledged by a durable PR comment:

```bash
gh api repos/{owner}/{repo}/pulls/{pr}/reviews \
  --paginate \
  --jq '.[] | select(.state != "DISMISSED" and .state != "PENDING" and (.body // "") != "") | {id, user: .user.login, state, body}'
```

Before acting on review `<review-id>`, search PR issue comments for `Fixed in <sha> for review <review-id>:`. Treat a matching marker as already handled.

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

For an addressed top-level review, use a normal PR comment carrying the review ID so later runs can correlate it:

```bash
gh pr comment {pr} --body "Fixed in {commit} for review {review_id}: {explanation}"
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

## Resolve And Verify

After the fix is pushed and the inline reply is visible, resolve the corresponding review thread:

```bash
gh api graphql \
  -f threadId='{thread-node-id}' \
  -f query='mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { id isResolved }
    }
  }'
```

Re-run the unresolved-thread query after all remote writes. Do not report review feedback complete while an actionable human or non-Codex thread remains. Codex threads are complete only when `handling-codex-reviews` reports its own terminal state.

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

1. **Build the worklist**: Query unresolved threads and unacknowledged submitted top-level reviews
2. **Route Codex**: Send existing Codex feedback to `handling-codex-reviews`; keep other reviewers here
3. **Fix and validate**: Address each grounded issue and run relevant checks
4. **Commit and push**: Publish an immutable fix commit
5. **Reply and acknowledge**: Reference the commit SHA inline or use the top-level review marker
6. **Resolve threads**: Resolve only after the pushed fix and reply are visible
7. **Request re-review**: Re-engage the human or bot already participating, using that reviewer's established mechanism
8. **Verify completion**: Re-query threads and top-level acknowledgement markers
9. **Keep Codex conditional**: Post one `@codex review` only when Codex was already part of the PR
10. **Avoid task-mode noise**: Never use `@codex` in routine "fixed" replies

**Important**: Don't amend commits after replying - the referenced commit hash becomes invalid.
