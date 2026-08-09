---
name: babysitting-prs
description: Opens, updates, and carries GitHub pull requests through review feedback, rebases, CI or Buildkite failures, existing Codex review, and optional merge. Use when asked to publish a branch, address PR feedback, babysit or prepare a PR, make it mergeable, land it, or merge it.
---

# Babysitting PRs

Drive a branch or GitHub pull request to the end state the user requested: published, updated, merge-ready, or merged.

## Authorization And Scope

- Inspecting local or PR state is read-only. A request to publish, update, address feedback, prepare, land, or merge authorizes the corresponding branch and PR writes; preserve unrelated work and avoid rewriting remote history unless explicitly authorized.
- Merge only when the user explicitly asks to merge, land, ship, queue, or get the PR merged. “Prepare to land,” “babysit,” “make mergeable,” and “ready for review” mean merge-ready only. Ambiguous follow-ups such as “looks good” do not grant new merge permission.
- Do not introduce GitHub Codex review. Continue it only when the PR already has Codex review activity or the user explicitly asks for it.

## Companion Skills

- Use `writing-pr-descriptions` before creating a PR and after material changes to an existing PR.
- Use `auto-review` when the user asks for it or the diff is materially risky: behavior, public contracts, data, security, concurrency, migrations, or cross-cutting structure. For small docs, metadata, configuration, or mechanical changes, use focused inspection and risk-matched validation instead of a mandatory full review loop.
- Use `handling-codex-reviews` only for an already-active or explicitly requested Codex loop.

## Workflow

Use a bounded loop, normally no more than three fix cycles. Batch related fixes before pushing.

1. **Resolve the target and requested end state**
   - Read repository instructions, `git status`, branch, remotes, and existing PR metadata.
   - Identify the base and current head SHA. Preserve unrelated dirty files.
   - If no PR exists and publication is in scope, use the repository’s branch convention, commit only intended changes, and push the branch. Do not create a PR when the user asked only for local work.

2. **Review and publish when needed**
   - Apply the risk rule above rather than running `auto-review` by rote.
   - Use `writing-pr-descriptions` against the final base-to-head diff and applicable template, then create or update a non-draft PR unless the user requested a draft.
   - Re-fetch the PR number, URL, head SHA, and merge state after publishing.

3. **Read current PR state**
   - Run `scripts/pr_babysit.sh status --pr <pr> --repo <owner/repo>`.
   - Treat unresolved review threads as the source of truth for inline feedback. Include submitted top-level reviews, but ignore withdrawn, pending, already acknowledged, or stale feedback that no longer applies to the current diff.

4. **Clear branch and review blockers**
   - Rebase or merge the base according to repository convention and resolve conflicts with the smallest correct change.
   - Classify feedback as actionable, already addressed, inaccurate, or requiring user judgement. Fix grounded items in one batch and run focused validation.
   - Commit and push before replying. Reply inline with `Fixed in <sha>: <what changed>`; for top-level reviews include the review ID so later runs can correlate it.
   - Add reactions only when they accurately acknowledge the feedback. Resolve a thread only after the pushed fix and reply are visible, then re-query unresolved threads.
   - Do not amend a commit after publishing replies that cite its SHA. Re-request only reviewers already participating, using their established mechanism; do not substitute or introduce a different bot.

5. **Handle Codex only when present**
   - If status reports existing Codex activity, pending review, actionable Codex feedback, or active `eyes`, use `handling-codex-reviews`.
   - If Codex is unavailable, continue with non-Codex blockers. Do not post another trigger or block on approval unless completing Codex review was explicitly requested.

6. **Clear CI blockers**
   - Run `scripts/pr_babysit.sh checks --pr <pr> --repo <owner/repo>` and inspect failures through GitHub first.
   - Use Buildkite-specific tools only when the PR has Buildkite checks and linked GitHub output is insufficient. Missing Buildkite access blocks only that diagnosis.
   - Fix branch-caused failures and retry one evidenced flaky or external failure once. Stop after two serious attempts at the same branch-caused failure.

7. **Refresh metadata and finish**
   - If code, behavior, scope, or evidence changed materially, run `writing-pr-descriptions` against the final head.
   - Before merge or handoff, re-fetch head SHA, reviews, unresolved threads, checks, and merge state. Never merge a head different from the reviewed green head.
   - Use the repository’s merge queue, auto-merge, or normal merge method. Delete the branch only when requested or established repository configuration does so.

## Helper Commands

```bash
scripts/pr_babysit.sh status --pr 32 --repo owner/repo
scripts/pr_babysit.sh resolve --pr 32 --repo owner/repo --comment-ids 12345,67890
scripts/pr_babysit.sh checks --pr 32 --repo owner/repo
```

The status result includes `merge_blockers`, `ready_to_merge`, unresolved review threads, check state, and Codex state. It is a fast summary, not a substitute for judgement.

## Stop And Report

Stop for missing authorization, contradictory feedback, required human or product judgement, unavailable essential credentials, branch protection, or a repeated blocker that evidence-based fixes did not clear.

Report the achieved state, PR URL, and exact blocker when unfinished. Mention commits or validation only when they materially help the handoff.
