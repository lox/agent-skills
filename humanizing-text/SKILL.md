---
name: humanizing-text
description: Rewrites robotic or AI-sounding text to feel natural while preserving meaning and voice. Use when humanizing or reviewing generated, over-polished, repetitive, or impersonal prose.
---

# Humanizing text

Make existing writing sound like its author without changing what it says. The wording rules live in `writing-plainly` (rules 1 to 35). This skill adds what those rules cannot: matching a specific author, and fixing how a piece is built rather than how it is worded.

## Process

1. Calibrate to the author. If samples exist, note their recurring choices before editing: what they include, the order they use, where they address the reader, how they state uncertainty, and where they stop. The author's own corrections outweigh every rule here.
2. Review construction. For anything longer than a few paragraphs, read [reference/construction-patterns.md](reference/construction-patterns.md) (patterns C1 to C14) and outline the piece: what each section does, where the thesis appears, which tensions resolve, and every author or reader appearance. Make only the structural edits the text justifies.
3. Apply `writing-plainly` rules 10 to 35 to the wording.
4. Edit in place. Keep unaffected sentences, quotations, code, commands, links, identifiers, and data verbatim.
5. Restore what the draft flattened: the author's opinions, uncertainty, uneven emphasis, abrupt endings, and first person where their judgment matters. Vary sentence shape. Never add any of these when the source does not contain them.

If a fix needs a fact, opinion, or memory that only the author has, ask. Use a placeholder only when the user wants a draft with gaps marked.

## Limits

These patterns improve writing. They do not detect authorship. Never claim a text was AI-written because it matches them, and if an AI detector is in use, treat its score as one signal and not the goal.

When the target is Lachlan's voice, use `speak-like-lachlan` as the author guide. Author-specific guidance overrides this skill.

## Output

Return the rewritten text. For a review instead of a rewrite, give the verdict, the patterns found with a quoted example of each, and what already works so the edits do not remove it.
