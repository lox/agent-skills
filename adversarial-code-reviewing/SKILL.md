---
name: adversarial-code-reviewing
description: Performs skeptical, high-signal code reviews that try to break confidence in a change by surfacing grounded, material failure modes. Use when asked for an adversarial review, ship/no-ship assessment, or a review focused on subtle production risks instead of balanced feedback.
---

# Adversarial code reviewing

Perform a skeptical code review that tries to disprove ship readiness.

## Use this when

- The user asks for an adversarial review, devil's-advocate review, or stress test of a change.
- The user wants a ship/no-ship assessment rather than a balanced summary.
- A diff, migration, infra change, or refactor needs scrutiny for subtle production risks.

## Stance

- Default to skepticism.
- Assume the change can fail in subtle, high-cost, or user-visible ways until the evidence says otherwise.
- Do not give credit for good intent, partial fixes, or likely follow-up work.
- If something only works on the happy path, treat that as a real weakness.
- Prefer one strong finding over several weak ones.

## Gather context first

1. Identify the review target: PR diff, staged changes, branch diff, or the specific files the user named.
2. Read the changed code and the surrounding callers, tests, schemas, and operational boundaries before judging it.
3. Compare against the previous behavior when reviewing regressions, refactors, or migrations; ask what invariant used to hold and whether this change preserves it.
4. Inspect adjacent paths that can invalidate the happy-path story: retries, rollbacks, permissions, background jobs, migrations, caching, and concurrency.
5. Run targeted verification when it changes confidence in a finding or rules one out.
6. If the evidence is incomplete, say that explicitly instead of filling gaps with speculation.

## Topic priority

Work in this order unless the user asked for a different emphasis:

1. Correctness and regression risk
2. Error handling and failure modes
3. Data integrity and state transitions
4. Security and trust boundaries
5. Performance and scalability in realistic hot paths
6. Testing and observability gaps that would let the issue ship unnoticed

Do not spend time on maintainability or style while higher-value risks remain.

## Where changes fail

Prioritize failures that are expensive, dangerous, or hard to detect:

- auth, permissions, tenant isolation, and trust boundaries
- data loss, corruption, duplication, and irreversible state changes
- rollback safety, retries, partial failure, and idempotency gaps
- race conditions, ordering assumptions, stale state, and re-entrancy
- empty-state, null, timeout, and degraded dependency behavior
- version skew, schema drift, migration hazards, and compatibility regressions
- observability gaps that would hide failure or make recovery harder

## Choose the right lens

Adapt the review to the kind of change under review instead of using one generic checklist:

- Application code: stress correctness, edge cases, error propagation, state management, and concurrency.
- Infrastructure, CI, and config changes: stress blast radius, permissions, provider drift, dependency ordering, rollback, secret exposure, and cost surprises.
- Schema, migration, and data-path changes: stress reversibility, backfill safety, partial rollout behavior, dual-read or dual-write assumptions, and idempotency.
- Dependency or supply-chain changes: stress install hooks, new network or filesystem access, permission changes, provenance, and whether the lockfile actually matches the intent.

## Review method

- Actively try to disprove the change.
- Look for violated invariants, missing guards, unhandled failure paths, and assumptions that stop being true under stress.
- Trace how bad inputs, retries, concurrent actions, or partially completed operations move through the code.
- If the user supplied a focus area, weight it heavily, but still report any other issue you can defend.
- Read enough surrounding context to explain why the vulnerable path is reachable, not just why a single line looks suspicious.

## What counts as a finding

- Every finding must be defensible from the repository context or tool output. Do not invent files, lines, code paths, incidents, attack chains, or runtime behavior you cannot support.
- Do not include style feedback, naming feedback, low-value cleanup, or speculative concerns without evidence.
- If reviewing a diff, prefer issues newly introduced or worsened by that change. Call out pre-existing risks only when they are necessary context.
- Withdraw or downgrade a finding if broader context disproves the initial suspicion. If a conclusion depends on inference, say so in the finding.

## Output

Write per `writing-plainly`. Findings first, ordered by severity. Each finding is one short paragraph: severity, file and line range, what goes wrong and on which reachable path, and the smallest change that removes the risk.

> High, `billing/charge.go:112-130`. `Charge` writes the ledger row before calling the gateway, and a gateway timeout returns without deleting it, so a retry double-books the customer. Insert the ledger row only after the gateway returns success, or key it on the gateway idempotency token.

Not as labeled fields ("Evidence: … Impact: … Recommendation: …") and not padded with what the change does well.

If high-priority areas consumed the review budget, list deferred concerns rather than silently dropping them.

When the user explicitly wants structured output or asks to mirror the upstream adversarial-review prompt, follow [reference/structured-output.md](reference/structured-output.md).

## Final check

Before finalizing, make sure each finding is:

- adversarial rather than stylistic
- tied to a concrete code location
- plausible under a real failure scenario
- actionable for the engineer fixing it
