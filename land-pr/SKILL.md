---
name: land-pr
description: "Prepares and, with explicit merge authorization, lands a GitHub pull request through review, CI, and the repository's merge path. Use when asked to prepare a PR to land, land a PR, merge this PR, ship this branch, or carry a branch through to merge."
---

# Land PR

Use this as the outer workflow for preparing a PR and, when explicitly authorized, merging it. A request to "prepare to land" means merge-ready only. A direct request to "land", "merge", "ship and merge", or "get this merged" authorizes the final merge once all gates pass. Ambiguous follow-ups such as "looks good", "go ahead", or "do it" do not grant new merge permission.

## Companion Skills

- Use `auto-review` first when available. Do not publish or merge while its status is `needs-attention` or `blocked` unless the user explicitly changes scope.
- After a PR exists, use `babysitting-prs` when available, passing through whether the request is prepare-only or merge-authorized.
- If a new PR is opened after auto-review, use `check-pr-description` when available so the title and body match the final diff.
- Use `humanizing-text` for substantial PR bodies or public-facing PR comments when available.

If a companion skill is unavailable, perform that step directly and report the degraded workflow only when it changes confidence or the outcome.

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
   - If detached or on a protected/default branch, use the repository's configured branch convention. For Lachlan's personal repositories, `lox/<topic>` is an intentional fallback; elsewhere use the authenticated GitHub username as the prefix when appropriate, or ask if the convention remains ambiguous.
   - If intended changes remain uncommitted after auto-review, stage only those files and commit following repository instructions.
   - Push the current branch.
   - Avoid rewriting remote history unless the user requested it or repo policy permits it.

4. Open or update the PR.
   - If the branch already has a PR, update it as needed; otherwise create a non-draft PR unless the user says the work is still in progress.
   - Follow repository PR title and body conventions. Start from the problem or motivation, describe impact, and include concrete examples when behavior or output changes.
   - Re-fetch the PR number, URL, head SHA, and merge state after publishing.

5. Babysit and, when authorized, merge.
   - Hand the PR to `babysitting-prs` with the GitHub Codex review boundary and the requested end state: merge-ready for preparation requests, merged for explicit landing requests.
   - Let babysitting clear stale base, review feedback, any already-active Codex feedback, CI, Buildkite, merge queue, and final merge blockers.
   - If babysitting requires non-trivial code fixes, batch narrow fixes, validate, commit, push, and run `auto-review` again before final merge.
   - Immediately before merge or queue submission, re-fetch the PR head SHA, required reviews, checks, and merge state. Do not merge if the head differs from the reviewed green head.
   - Respect the repository's branch protection and merge strategy. Do not delete the branch unless requested or configured as part of that strategy.

## Stop Conditions

Stop with `blocked` or `needs-attention` when:

- `auto-review` cannot reach `ready`.
- GitHub auth, PR creation, push, reviews, CI, branch protection, or merge permission blocks progress. Missing Buildkite auth blocks only Buildkite-specific diagnostics when the PR uses Buildkite and GitHub does not expose enough detail.
- A human, product, security, migration, or rollout decision is required.
- The same CI or review blocker recurs after `babysitting-prs`' bounded attempts.

## Output

State `Status: prepared | landed | needs-attention | blocked`, then include the PR URL or number, branch, commits pushed, validation run, current head SHA, merge method or merge SHA when known, and the exact remaining blocker when not prepared or landed.
