---
name: land-pr
description: "Run the full code-to-merged-PR workflow: auto-review the current branch or PR, create or update a GitHub PR, babysit it through reviews and CI, merge it, and report the final state. Use when asked to land a PR, land this, ship this branch, get this into a PR and merge it, or otherwise carry code from local changes or a current branch to a merged PR."
---

# Land PR

Land means merged, not just merge-ready. Use this as the outer workflow; load companion skills and let them own their parts.

## Required Companion Skills

- Load and use `auto-review` first for the current branch or PR. Do not publish or merge while auto-review status is `needs-attention` or `blocked` unless the user explicitly changes scope.
- After a PR exists, load and use `babysitting-prs` with merge authorization. A `land-pr` request is an explicit request to merge once the PR is safe to merge.
- If a new PR is opened after auto-review, run `check-pr-description` before babysitting so the title and body match the final diff.
- Use `humanizing-text` for substantial PR bodies or public-facing PR comments when available.

## GitHub Codex Review Boundary

- Use `auto-review` and its local companion skills as the review mechanism for every PR.
- Do not post an initial `@codex review` comment or otherwise introduce GitHub Codex review while landing a PR.
- Continue an existing GitHub Codex review loop only when the PR already has an `@codex review` comment or a Codex-authored `eyes` reaction. Pass this boundary to `babysitting-prs`; a bare landing request is not authorization to start GitHub Codex review.

## Workflow

1. Resolve the target.
   - Read repository instructions, `git status`, branch, remotes, and existing PR metadata.
   - Preserve unrelated dirty files and do not absorb unrelated work into commits.
   - If there is no existing PR and no local branch or diff to land, stop with `blocked`.

2. Run auto-review.
   - Run `auto-review` against the exact branch or PR diff.
   - Fix only grounded, in-scope findings, validate, and re-review until `ready` or a blocker remains.
   - Keep commits and pushes scoped to the landing request.

3. Branch, commit, and push.
   - If detached or on a protected/default branch, create a `lox/` branch unless the user named a branch.
   - If intended changes remain uncommitted after auto-review, stage only those files and commit following repository instructions.
   - Push the current branch.
   - Avoid rewriting remote history unless the user requested it or repo policy permits it.

4. Open or update the PR.
   - If the branch already has a PR, update it as needed; otherwise create a non-draft PR unless the user says the work is still in progress.
   - Follow repository PR title and body conventions. Start from the problem or motivation, describe impact, and include concrete examples when behavior or output changes.
   - Re-fetch the PR number, URL, head SHA, and merge state after publishing.

5. Babysit and merge.
   - Hand the PR to `babysitting-prs` with the GitHub Codex review boundary above; the desired end state is merged, not merely ready.
   - Let babysitting clear stale base, review feedback, any already-active Codex feedback, CI, Buildkite, merge queue, and final merge blockers.
   - If babysitting requires non-trivial code fixes, batch narrow fixes, validate, commit, push, and run `auto-review` again before final merge.

## Stop Conditions

Stop with `blocked` or `needs-attention` when:

- `auto-review` cannot reach `ready`.
- GitHub auth, Buildkite auth, PR creation, push, reviews, CI, branch protection, or merge permission blocks progress.
- A human, product, security, migration, or rollout decision is required.
- The same CI or review blocker recurs after `babysitting-prs`' bounded attempts.

## Output

State `Status: landed | needs-attention | blocked`, then include the PR URL or number, branch, commits pushed, validation run, merge method or merge SHA when known, and the exact remaining blocker when not landed.
