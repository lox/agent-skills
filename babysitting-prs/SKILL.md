---
name: babysitting-prs
description: Opens, updates, and carries GitHub pull requests through review feedback, rebases, CI or Buildkite failures, existing Codex review, and optional merge. Use when asked to publish a branch, address PR feedback, babysit or prepare a PR, make it mergeable, land it, or merge it.
---

# Babysitting PRs

Take a branch or pull request to the state the user asked for: published, updated, merge-ready, or merged.

## Authorization

Reading local or PR state is always allowed. A request to publish, update, address feedback, prepare, land, or merge authorizes the matching branch and PR writes. Do not rewrite remote history unless asked.

Merge only when the user says merge, land, ship, queue, or get it merged. "Prepare to land", "babysit", "make mergeable", and "ready for review" mean merge-ready and stop there. A later "looks good" does not grant merge permission.

Do not introduce GitHub Codex review. If the PR already has Codex activity, or the user asks for it, use `handling-codex-reviews`.

## Companion skills

Run `writing-pr-descriptions` before creating a PR and again whenever the diff of an existing PR changes. Run `auto-review` when the user asks for it or the diff is risky: behavior, public contracts, data, security, concurrency, migrations, or cross-cutting structure. For small docs, metadata, config, or mechanical changes, inspect directly and validate in proportion instead.

## Workflow

Batch related fixes before pushing. Normally no more than three fix cycles.

1. Resolve the target. Read repository instructions, `git status`, branch, remotes, and existing PR metadata. Note the base and head SHA. Leave unrelated dirty files alone. If no PR exists and publishing is in scope, use the repository's branch convention, commit only the intended changes, and push.

2. Review and publish. Apply the risk rule above. Run `writing-pr-descriptions` against the base-to-head diff, then create or update a non-draft PR unless the user asked for a draft. Re-fetch the PR number, URL, head SHA, and merge state.

3. Read PR state with `scripts/pr_babysit.sh status --pr <pr> --repo <owner/repo>`. Unresolved review threads are the source of truth for inline feedback. Include submitted top-level reviews. Ignore withdrawn, pending, acknowledged, or stale feedback that no longer applies to the diff.

4. Clear review blockers. Rebase or merge the base per repository convention and resolve conflicts with the smallest correct change. Sort feedback into actionable, already addressed, inaccurate, or needing the user. Fix the actionable items in one batch and validate. Commit and push before replying. Reply inline with `Fixed in <sha>: <what changed>`; for a top-level review include the review ID. Replies follow `writing-plainly`: one or two sentences, no thanks, praise, or apology, and evidence when declining.

   > Fixed in a1b2c3d: `parseLimit` now rejects negative values and the test covers -1 and 0.

   > Not changed. `flush` already runs under `mu` (line 88), so the extra lock here would deadlock on the retry path.

   React only when the reaction is accurate. Resolve a thread only after the fix and reply are visible, then re-query. Never amend a commit after a reply cites its SHA. Re-request review only from reviewers already on the PR.

5. If status shows Codex activity, a pending Codex review, or an active `eyes`, use `handling-codex-reviews`. If Codex is unavailable, continue with other blockers and do not post another trigger.

6. Clear CI. Run `scripts/pr_babysit.sh checks --pr <pr> --repo <owner/repo>` and read failures through GitHub first. Use Buildkite tools only when the PR has Buildkite checks and the GitHub output is not enough. Fix failures the branch caused. Retry an evidenced flaky or external failure once. Stop after two real attempts at the same branch-caused failure.

7. Finish. Before merge or handoff, re-fetch head SHA, reviews, unresolved threads, checks, and merge state. Never merge a head other than the reviewed green one. Use the repository's merge queue, auto-merge, or normal merge method. Delete the branch only when asked or when the repository is configured to.

## Helper commands

```bash
scripts/pr_babysit.sh status --pr 32 --repo owner/repo
scripts/pr_babysit.sh resolve --pr 32 --repo owner/repo --comment-ids 12345,67890
scripts/pr_babysit.sh checks --pr 32 --repo owner/repo
```

`status` returns `merge_blockers`, `ready_to_merge`, unresolved threads, check state, and Codex state. It is a summary, not a substitute for reading the PR.

## Stop and report

Stop for missing authorization, contradictory feedback, a call that needs a human, missing credentials, branch protection, or a blocker that two evidence-based fixes did not clear.

Report the state reached, the PR URL, and the exact blocker if unfinished, per `writing-plainly`. Mention commits or validation only when the reader needs them.
