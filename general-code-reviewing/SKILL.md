---
name: general-code-reviewing
description: Orchestrates a broad code review with separate ship-risk and simplicity passes, then synthesizes both. Use for general PR, diff, or code reviews when the user did not request only one narrower review lens; delegates only when explicitly requested.
---

# General Code Reviewing

Run a broad review without flattening distinct review lenses into mush. Run separate passes for ship risk and simplicity, then synthesize the results into one findings-first review.

## Use This When

- The user asks for a general code review, PR review, diff review, or broad review.
- The user wants an overall merge/readiness opinion and did not explicitly request only adversarial, security, simplicity, or thermonuclear review.
- The change is large enough that independent review lenses are likely to catch different classes of problems.

Use a narrower skill directly only when the user requested only that lens. A focus or emphasis within a broad review does not suppress the other pass.

For a narrow request, use `adversarial-code-reviewing` for adversarial, ship/no-ship, security, or production-risk review. Use `simplicity-review` for simplicity, YAGNI, minimalism, maintainability, over-engineering, abstraction, or structural review. Reserve `thermo-nuclear-code-quality-review` for explicit thermo-nuclear, thermonuclear, especially harsh, or deep code-quality requests.

## Review Lenses

Use two independent passes:

- `adversarial-code-reviewing`: ship risk, correctness, regressions, data integrity, security, migrations, rollback, concurrency, performance, and observability gaps.
- `simplicity-review`: unnecessary code, speculative generality, avoidable dependencies, wrong-layer fixes, abstraction quality, and whether structure reduces or increases conceptual load.

Do not ask either pass to cover the other's job. Overlap is useful evidence, but separate perspectives are the point.

## Running The Passes

Default to running both review passes sequentially in the current agent. A normal request like "review this PR" or "review this diff" does not authorize spawning sub-agents.

Use delegation only when the current user request explicitly asks for sub-agents, delegation, parallel agents, or parallel review work. When that permission is present and supported delegation tools are available, run both review passes in parallel. Otherwise run them sequentially in the current agent.

Before running either pass, identify the exact target:

1. PR number, branch diff, staged diff, commit range, or named files.
2. Base revision for comparison when reviewing a branch or PR.
3. Any user-supplied focus area or constraints.

Whether the passes are local or delegated, use the same concrete target for both, but keep their skill lenses and output contracts separate. Review passes must not edit files.

### Adversarial Pass Contract

Use `adversarial-code-reviewing` and return:

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

### Simplicity Pass Contract

Use `simplicity-review` and return:

```json
{
  "lens": "simplicity",
  "verdict": "approve | needs-attention",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "title": "string",
      "file": "string",
      "line_start": 1,
      "line_end": 1,
      "body": "what does not need to exist or what structural quality regressed, and why it matters",
      "remedy_rung": "delete | reuse | stdlib | native-platform | existing-dependency | idiom | direct-code | new-structure",
      "replacement": "the concrete smaller implementation",
      "confidence": 0.0
    }
  ],
  "checked": ["string"],
  "deferred": ["string"]
}
```

If the user explicitly requested sub-agents but they are unavailable, run both skill passes yourself and say the review was sequential rather than delegated.

## Synthesis

Read both results before writing the final review. Do not average the verdicts.

Deduplicate findings that point to the same root cause, but keep both lenses visible when they add different evidence. A finding can be both a ship risk and a simplicity risk.

Classify the final verdict as:

- `no-ship`: at least one critical/high ship-risk finding, or severe unnecessary complexity that should block merge before it hardens into the codebase.
- `needs-attention`: material findings exist, but they are not clear no-ship blockers.
- `approve`: neither pass produced a substantive finding that survives synthesis.

Separate:

- merge blockers
- non-blocking follow-ups
- what was checked
- what was deferred because of missing context or review budget

## Output

If the user, platform, connector, or integration requires a specific output format or schema, honor that format first. Apply the findings-first prose format only for normal interactive reviews without a stricter caller-required format.

For normal interactive reviews, use:

1. Verdict line: `Verdict: approve | needs-attention | no-ship`
2. Findings ordered by severity, each with file and line references.
3. Short synthesis explaining how the two lenses affected the verdict.
4. Checked/deferred notes only when they materially qualify confidence.

Keep the final answer concise. Do not include raw sub-agent transcripts unless the user asks for them.

If there are no findings, say that clearly and mention the main residual risk or test gap.

## Grounding Rules

- Every final finding must be defensible from repository context, diff context, tool output, or a sub-agent result.
- Resolve conflicts between sub-agents by checking the code yourself before reporting the finding.
- Downgrade or omit speculative findings that cannot be tied to a reachable path or concrete simplicity regression.
- Preserve a dissenting sub-agent concern in deferred notes when it seems plausible but cannot be verified in the current review budget.
