---
name: adversarial-code-reviewing
description: Performs skeptical, high-signal code reviews that try to break confidence in a change by surfacing grounded, material failure modes. Use when asked for an adversarial review, ship/no-ship assessment, or a review focused on subtle production risks instead of balanced feedback.
---

# Adversarial code reviewing

Try to disprove that the change is safe to ship. Assume it fails in a subtle, expensive, or user-visible way until the code says otherwise. Give no credit for intent, partial fixes, or promised follow-ups. A happy path that only works on the happy path is a finding. One strong finding beats five weak ones.

## Read before judging

Identify the target: PR diff, staged changes, branch diff, or the files the user named. Read the changed code and its callers, tests, schemas, and operational edges. For refactors and migrations, name the invariant that used to hold and check whether it still does. Follow retries, rollbacks, permissions, background jobs, caching, and concurrent access through the change, because those paths break the happy-path story. Run a targeted check when it would confirm or rule out a finding. When evidence is missing, say so rather than filling the gap.

## Where to look, in order

1. Correctness and regressions.
2. Error handling and partial failure.
3. Data integrity and state transitions.
4. Security and trust boundaries.
5. Performance on realistic hot paths.
6. Test and observability gaps that would let the bug ship unnoticed.

Do not spend time on style or maintainability while anything above is unchecked. If the user named a focus, weight it heavily but still report anything else you can defend.

The expensive failures cluster in a few places: auth, permissions, and tenant isolation; data loss, duplication, and irreversible writes; retries, rollbacks, and idempotency; races, ordering assumptions, stale state, and re-entrancy; empty, null, timeout, and degraded-dependency behavior; version skew, schema drift, and migration order; and observability gaps that hide failure.

Match the lens to the change. Application code: edge cases, error propagation, state, concurrency. Infrastructure and CI: blast radius, permissions, provider drift, ordering, rollback, secret exposure, cost. Schema and data paths: reversibility, backfill safety, partial rollout, dual-read or dual-write assumptions. Dependencies: install hooks, new network or filesystem access, provenance, and whether the lockfile matches the intent.

## What counts as a finding

A finding names a file and line, a reachable path, and what goes wrong on it. It is supported by the repository or tool output, not by an imagined incident. It is new or worsened by this diff; mention pre-existing risk only as context. It is not style, naming, or cleanup. If wider context disproves it, withdraw or downgrade it, and say when a conclusion rests on inference.

## Output

Write per `writing-plainly`. Findings first, ordered by severity. Each finding is one short paragraph: severity, file and line range, what goes wrong and on which path, and the smallest change that removes the risk.

> High, `billing/charge.go:112-130`. `Charge` writes the ledger row before calling the gateway, and a gateway timeout returns without deleting it, so a retry double-books the customer. Insert the ledger row only after the gateway returns success, or key it on the gateway idempotency token.

Not as labeled fields, and not padded with what the change does well. If the review budget ran out before low-priority areas, list what was deferred.

When the user wants structured output or the upstream adversarial-review prompt, follow [reference/structured-output.md](reference/structured-output.md).
