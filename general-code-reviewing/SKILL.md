---
name: general-code-reviewing
description: Runs a broad code review with separate ship-risk and simplicity lenses, then synthesizes grounded findings. Use for general PR, diff, or code reviews when the user did not request only one narrower review lens.
---

# General Code Reviewing

Review the same concrete target from two independent perspectives, then return one concise findings-first result.

## Choose The Target

Identify the PR, branch diff, staged diff, commit range, or named files; use a fresh base revision and preserve any user-supplied focus. Review passes are read-only.

Use a narrower skill alone only when the user requested only that lens:

- `adversarial-code-reviewing` for ship risk, correctness, regressions, data integrity, security, migrations, concurrency, performance, and operability.
- `simplicity-review` for YAGNI, maintainability, unnecessary code, wrong-layer fixes, abstractions, dependencies, or an explicitly harsh code-quality review.

## Run And Synthesize

1. Apply `adversarial-code-reviewing` to the exact target.
2. Independently apply `simplicity-review` to the same target.
3. Run both sequentially in the current agent unless the user explicitly requested sub-agents or parallel review. If so, delegate the two independent passes in parallel when supported.
4. Deduplicate findings that share a root cause. Keep both lenses only when they contribute different material evidence.
5. Verify conflicts against the code. Omit speculative concerns that cannot be tied to a reachable path or concrete complexity regression.

Verdict:

- `no-ship`: a critical or high ship risk, or severe complexity that should not harden into the codebase.
- `needs-attention`: material findings exist but are not clear no-ship blockers.
- `approve`: no substantive finding survives synthesis.

## Output

Honor a caller-required format when present. Otherwise report:

1. Verdict.
2. Findings ordered by severity with file and line references, evidence, impact, and the smallest concrete remedy.
3. Checked or deferred areas only when they materially qualify confidence.

If there are no findings, say so directly and mention only the main residual risk or test gap. Do not expose internal pass transcripts or schemas.
