# Structured output

Use this only when the user explicitly wants structured output or asks to mirror the upstream adversarial-review prompt. Return compact JSON matching this schema, not wrapped in markdown fences:

```json
{
  "verdict": "approve | needs-attention",
  "summary": "string",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "title": "string",
      "body": "string",
      "file": "string",
      "line_start": 1,
      "line_end": 1,
      "confidence": 0.0,
      "recommendation": "string"
    }
  ],
  "next_steps": ["string"]
}
```

- Use `needs-attention` if there is any risk worth blocking on.
- Use `approve` only if you cannot support any substantive adversarial finding from the provided context.
- Keep the summary terse and decisive.
- Lower confidence when a conclusion depends on inference, and say so in the body.
