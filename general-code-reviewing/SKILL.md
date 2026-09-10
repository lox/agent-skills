---
name: general-code-reviewing
description: Runs a broad code review with separate ship-risk and simplicity lenses, then synthesizes grounded findings. Use for general PR, diff, or code reviews when the user did not request only one narrower review lens.
---

# General code reviewing

Review the same target from two independent perspectives, then return one concise findings-first result.

## Choose the target

Identify the PR, branch diff, staged diff, commit range, or named files; use a fresh base revision and preserve any user-supplied focus. Review passes are read-only.

Use a narrower skill alone only when the user requested only that lens:

- `adversarial-code-reviewing` for ship risk, correctness, regressions, data integrity, security, migrations, concurrency, performance, and operability.
- `simplicity-review` for YAGNI, maintainability, unnecessary code, wrong-layer fixes, abstractions, dependencies, or an explicitly harsh code-quality review.

## Run and synthesize

1. Apply `adversarial-code-reviewing` to the exact target.
2. Independently apply `simplicity-review` to the same target.
3. Run both sequentially in the current agent unless the user explicitly requested sub-agents or parallel review. If so, delegate the two independent passes in parallel when supported.
4. Deduplicate findings that share a root cause. Keep both lenses only when they contribute different evidence.
5. Verify conflicts against the code. Omit speculative concerns that cannot be tied to a reachable path or a specific complexity regression.

Verdict:

- `no-ship`: a critical or high ship risk, or severe complexity that should not harden into the codebase.
- `needs-attention`: real findings exist but are not clear no-ship blockers.
- `approve`: no substantive finding survives synthesis.

## Output

Use the caller's required format when there is one. Otherwise, per `writing-plainly`:

1. The verdict, in one line.
2. Findings ordered by severity. Each is one short paragraph, as in `adversarial-code-reviewing` and `simplicity-review`: severity, file and line, what goes wrong or what does not need to exist, and the smallest fix. Not a set of labeled fields.
3. Checked or deferred areas only when they change how much to trust the verdict.

If there are no findings, say so in a sentence and name the main residual risk or test gap. Do not expose internal pass transcripts or schemas.
