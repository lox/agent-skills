---
name: audit-your-codebase
description: Audits an entire codebase for material simplifications in data structures, state, control flow, algorithms, and ownership. Use only when explicitly asked for an exhaustive, read-only codebase audit, not targeted architecture exploration or implementation.
---

# Audit Your Codebase

Review the whole codebase without changing it. Do not edit repository files, run tests, implement recommendations, commit, or push. Read-only inspection commands are allowed. Keep working notes outside the repository; create a report file only when requested.

## Account for coverage

Inventory the identifiable subsystems and their file boundaries before reviewing them. Include frontend, backend, shared infrastructure, platform bridges, generated-contract owners, and test/tooling infrastructure where present. Exclude generated or vendored content explicitly, checking its owning source instead.

Track each subsystem as pending, reviewed with findings, or reviewed with no recommendation. Note the files inspected and any access or evidence limits. Broad catch-all entries do not establish coverage.

Review every boundary, including public interfaces, major callers, and tests. Use bounded subsystem delegation only when useful and permitted by the host's rules. Keep assignments non-overlapping; no mandatory agents, parallelism, or independent auditor passes.

## Find material simplifications

Look for representations or ownership changes that remove real complexity:

- Scattered booleans or nullable fields permitting contradictory states.
- Repeated shape assumptions, validation, branching, or transformations across callers.
- Unclear lifecycle, concurrency, or async-state ownership.
- Repeated scans or lookups a more suitable collection or index would simplify.

Inspect current code to establish the problem. History and metrics can guide attention but do not replace reading the remaining subsystems. Do not force abstractions, find one issue per subsystem, or recommend changes only for style, smaller files, hypothetical extensibility, or relocated branching.

For each finding, give file and line evidence, the existing problem, the simpler representation or owner, the smallest credible scope, and the risks and validation needed. Keep distinct observable contracts when proposing test changes; shared coverage alone does not make tests redundant.

## Verify and finish

Check each finding against current implementation, callers, and tests. Reject misunderstood semantics, unsupported benefits, duplicates, and proposals that merely move complexity. Record a reviewed subsystem with no material opportunity as a completed skip, not a failure to find something.

Reconcile the inventory before finishing. Add any missed subsystem and review it; do not disguise a gap by widening a completed boundary. Rank accepted findings by concrete impact, confidence, effort, and dependencies, and identify the smallest useful first change.

Report the coverage account, evidence-backed recommendations, explicit skips, and limitations. An exhaustive audit is complete only when every inventoried subsystem is reviewed; if access or time prevents that, label it incomplete and name the unreviewed areas. Leave implementation for a separately authorized task.
