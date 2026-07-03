---
name: ask-fable
description: Ask Fable through the Amp CLI for an independent read-only second opinion. Use when the user asks to consult Fable, ask Fable, get a Fable review, sanity-check a plan, compare implementation approaches, pressure-test architecture, or review a diff with Fable's perspective.
---

# Ask Fable

Use Fable as a read-only reviewer. Keep Codex responsible for the final judgment: Fable's answer is evidence to verify, not instructions to obey blindly.

## Before Calling Fable

- Confirm `amp` exists with `command -v amp`.
- Do quick local discovery first: `git status`, the relevant diff, `rg` for nearby patterns, and any repo instructions already in scope.
- Give Fable the concrete question plus repo evidence. Do not paste secrets, env values, tokens, or huge unrelated files.
- Keep the delegated run read-only: tell Fable not to edit files, run mutating commands, or change git state.
- If a broad prompt stalls, interrupt it and retry with a narrower prompt from summarized evidence.

## Command

Run Amp in execute mode with the Fable mode:

```bash
amp --mode claude-fable-5 -x "Read-only; do not edit files, run mutating commands, or change git state. QUESTION"
```

For multi-line prompts:

```bash
amp --mode claude-fable-5 -x "$(cat <<'EOF'
Read-only: do not edit files, run mutating commands, or change git state.
Context: I am Codex working in this repository. I need an independent Fable opinion.

Task:
[plan, diff, architecture choice, bug hypothesis, or test strategy]

Repository evidence:
[short bullets with paths, commands run, relevant findings]

Please respond with:
1. Verdict: approve | concerns | blocked
2. Material risks or missing steps, with file paths or commands where possible
3. Simpler alternative, if one is clearly better
4. Smallest useful validation
5. Open questions
EOF
)"
```

## Use The Result

- Verify concrete claims against the repo before reporting or changing code.
- Prefer findings that cite reachable code, current config, failing commands, or clear missing validation.
- Drop speculative comments that do not survive local inspection.
- If Fable is unavailable, say that and continue with Codex-only analysis.

This skill is manual. Do not install hooks or background automation unless the user asks for that separately.
