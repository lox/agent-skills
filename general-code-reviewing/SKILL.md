---
name: general-code-reviewing
description: Runs a broad code review with separate ship-risk and simplicity lenses, then synthesizes grounded findings. Use for general PR, diff, or code reviews when the user did not request only one narrower review lens.
---

# General code reviewing

Review one target from two independent angles, then return one findings-first result.

## Target

Identify the PR, branch diff, staged diff, commit range, or named files. Use a fresh base revision. Keep any focus the user gave. Review passes are read-only.

Use `adversarial-code-reviewing` alone only when the user asked only for ship risk, and `simplicity-review` alone only when they asked only for simplicity, YAGNI, or a harsh code-quality review.

## Run

1. Apply `adversarial-code-reviewing` to the target.
2. Apply `simplicity-review` to the same target, independently.
3. Run both in this agent, one after the other, unless the user asked for sub-agents or parallel review.
4. Merge findings that share a root cause. Keep both lenses only when they add different evidence.
5. Check conflicts between the lenses against the code. Drop anything not tied to a reachable path or a specific complexity regression.

Verdict: `no-ship` for a critical or high ship risk or severe complexity that should not harden into the codebase; `needs-attention` for real findings that are not clear blockers; `approve` when nothing survives synthesis.

## Output

Write per `writing-plainly`. The verdict in one line, then findings by severity in the one-paragraph form the two lens skills use: severity, file and line, what goes wrong or what does not need to exist, and the smallest fix. Mention checked or deferred areas only when they change how much to trust the verdict.

With no findings, say so in one sentence and name the main residual risk or test gap. Do not expose pass transcripts or schemas.
