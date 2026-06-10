---
name: general-code-reviewing
description: Orchestrate a broad code review by delegating ship-risk review to adversarial-code-reviewing and maintainability review to thermo-nuclear-code-quality-review, then synthesize both. Use for general PR reviews, diff reviews, code reviews, or broad review requests when the user did not ask for only one narrower review lens.
---

# General Code Reviewing

Run a broad review without flattening distinct review lenses into mush. Delegate separate passes for ship risk and structural maintainability, then synthesize the results into one findings-first review.

## Use This When

- The user asks for a general code review, PR review, diff review, or broad review.
- The user wants an overall merge/readiness opinion and did not explicitly request only adversarial, security, maintainability, or thermonuclear review.
- The change is large enough that independent review lenses are likely to catch different classes of problems.

If the user explicitly asks for an adversarial, ship/no-ship, security, or production-risk review, use `adversarial-code-reviewing` directly. If they explicitly ask for a thermonuclear, maintainability, code-quality, abstraction, or structural review, use `thermo-nuclear-code-quality-review` directly.

## Review Lenses

Use two independent passes:

- `adversarial-code-reviewing`: ship risk, correctness, regressions, data integrity, security, migrations, rollback, concurrency, performance, and observability gaps.
- `thermo-nuclear-code-quality-review`: structural code quality, abstraction quality, file sprawl, special-case branching, wrong-layer logic, unnecessary indirection, and maintainability regressions.

Do not ask either pass to cover the other's job. Overlap is useful evidence, but separate perspectives are the point.

## Delegation

When multi-agent tools are available, spawn both review passes as sub-agents in parallel. If the spawn tools are not already available, search for multi-agent or sub-agent tools before falling back to local sequential review.

Before spawning, identify the exact target:

1. PR number, branch diff, staged diff, commit range, or named files.
2. Base revision for comparison when reviewing a branch or PR.
3. Any user-supplied focus area or constraints.

Give each sub-agent the same concrete target, but a different skill and output contract. Review sub-agents must not edit files.

### Adversarial Sub-Agent Prompt

Ask the sub-agent to use `adversarial-code-reviewing` and return:

```json
{
  "lens": "ship-risk",
  "verdict": "approve | needs-attention",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "title": "string",
      "file": "string",
      "line_start": 1,
      "line_end": 1,
      "body": "what can go wrong, why this path is reachable, likely impact, and concrete recommendation",
      "confidence": 0.0
    }
  ],
  "checked": ["string"],
  "deferred": ["string"]
}
```

### Thermonuclear Sub-Agent Prompt

Ask the sub-agent to use `thermo-nuclear-code-quality-review` and return:

```json
{
  "lens": "maintainability",
  "verdict": "approve | needs-attention",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "title": "string",
      "file": "string",
      "line_start": 1,
      "line_end": 1,
      "body": "what structural quality regressed, why it matters, and concrete simplification or decomposition",
      "confidence": 0.0
    }
  ],
  "checked": ["string"],
  "deferred": ["string"]
}
```

If sub-agents are unavailable, run both skill passes yourself and say the review was sequential rather than delegated.

## Synthesis

Read both results before writing the final review. Do not average the verdicts.

Deduplicate findings that point to the same root cause, but keep both lenses visible when they add different evidence. A finding can be both a ship risk and a maintainability risk.

Classify the final verdict as:

- `no-ship`: at least one critical/high ship-risk finding, or a severe maintainability regression that should block merge before it hardens into the codebase.
- `needs-attention`: material findings exist, but they are not clear no-ship blockers.
- `approve`: neither pass produced a substantive finding that survives synthesis.

Separate:

- merge blockers
- non-blocking follow-ups
- what was checked
- what was deferred because of missing context or review budget

## Output

Use findings-first review format:

1. Verdict line: `Verdict: approve | needs-attention | no-ship`
2. Findings ordered by severity, each with file and line references.
3. Short synthesis explaining how the two lenses affected the verdict.
4. Checked/deferred notes only when they materially qualify confidence.

Keep the final answer concise. Do not include raw sub-agent transcripts unless the user asks for them.

If there are no findings, say that clearly and mention the main residual risk or test gap.

## Grounding Rules

- Every final finding must be defensible from repository context, diff context, tool output, or a sub-agent result.
- Resolve conflicts between sub-agents by checking the code yourself before reporting the finding.
- Downgrade or omit speculative findings that cannot be tied to a reachable path or concrete maintainability regression.
- Preserve a dissenting sub-agent concern in deferred notes when it seems plausible but cannot be verified in the current review budget.
