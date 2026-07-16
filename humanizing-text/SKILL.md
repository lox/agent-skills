---
name: humanizing-text
description: Rewrites robotic or AI-sounding text to feel natural while preserving meaning and voice. Use when humanizing or reviewing generated, over-polished, repetitive, or impersonal prose. Covers 24 wording patterns and 14 construction patterns.
---

# Humanizing Text

Make writing sound human without changing its meaning. Generic writing can fail at two layers: wording (patterns 1-24 below) and construction, i.e. how the piece is built (patterns 25-38). Use these as review prompts, not a checklist the text must obey.

## Task

1. **Calibrate to the author** - If source samples exist, identify their recurring choices before editing: what they include, how they order it, where they address the reader, how they handle uncertainty, and where they stop.
2. **Review construction first** - For multi-paragraph text, read `reference/construction-patterns.md` and check patterns 25-38. Make only grounded structural edits before polishing wording; do not restructure a piece to satisfy the checklist.
3. **Identify surface patterns** - Scan for patterns 1-24 below.
4. **Edit surgically** - Preserve unaffected spans and exact material such as quotations, code, commands, links, identifiers, and data. Prefer local edits over regeneration.
5. **Preserve meaning and fingerprint** - Keep the message, format, and the author's characteristic choices intact, including useful irregularities.
6. **Restore voice** - Surface real personality or experience that the draft flattened. Never invent it.

These patterns are editorial heuristics for making writing better, not a detector. Never use them to claim a text was AI-written.

## Preserve the Author's Fingerprint

There is no single structure that makes prose human. When author samples exist:

- compare outlines, not just sentences
- preserve the author's selection, order, specificity, directness, and ending shape
- treat the author's corrections as stronger evidence than generic rules

When the target is Lachlan's voice, use `speak-like-lachlan` as the author guide. Author-specific guidance and same-mode examples override generic patterns in this skill.

Do not add direct reader address, time jumps, references, anecdotes, jokes, or ambivalence merely to make the text look human. If a fix needs a fact, opinion, or memory that is not present, ask; use a placeholder only when the user wants a draft with gaps marked.

## Restore Voice

Removing generic patterns is only half the job. Recover what the author actually thinks and notices:

- own opinions and uncertainty when the source supports them
- vary rhythm instead of making every sentence the same shape
- use first person when the author's judgment matters
- preserve genuine asides, abrupt endings, and uneven emphasis; do not manufacture mess
- ground feelings in available detail: "The page went off at 3am, again. It was frustrating" beats invented cinematic imagery

---

## The 24 Surface Patterns

### Content Patterns

**1. Undue emphasis on significance/legacy**
Watch for: stands/serves as, testament, pivotal moment, crucial role, underscores importance, reflects broader, symbolizing, marking/shaping, evolving landscape
- Before: "marking a pivotal moment in the evolution of regional statistics"
- After: "was established in 1989 to collect regional statistics"

**2. Undue emphasis on notability**
Watch for: independent coverage, media outlets, active social media presence
- Before: "cited in NYT, BBC, Financial Times"
- After: "In a 2024 NYT interview, she argued..."

**3. Superficial -ing analyses**
Watch for: highlighting, emphasizing, reflecting, symbolizing, showcasing, fostering
- Before: "symbolizing Texas bluebonnets, reflecting the community's connection"
- After: "The architect said these colors reference local bluebonnets"

**4. Promotional language**
Watch for: boasts, vibrant, rich, profound, nestled, groundbreaking, renowned, breathtaking, stunning
- Before: "Nestled within the breathtaking region..."
- After: "is a town in the Gonder region, known for its weekly market"

**5. Vague attributions**
Watch for: Experts believe, Some critics argue, Industry reports, Observers have cited
- Before: "Experts believe it plays a crucial role"
- After: "according to a 2019 survey by the Chinese Academy of Sciences"

**6. Formulaic challenges sections**
Watch for: Despite challenges... continues to thrive, Future Outlook
- Before: "Despite these challenges, continues to thrive"
- After: "Traffic congestion increased after 2015 when three IT parks opened"

### Language Patterns

**7. Stock vocabulary clusters**
Watch for repeated or unnecessary use of: Additionally, delve, crucial, enhance, fostering, interplay, intricate, landscape (abstract), pivotal, showcase, tapestry, testament, underscore, vibrant. A listed word is not, by itself, a reason to edit it.

**8. Copula avoidance**
Watch for: serves as, stands as, boasts, features, offers (instead of is/are/has)
- Before: "Gallery 825 serves as the exhibition space"
- After: "Gallery 825 is the exhibition space"

**9. Negative parallelisms**
Watch for: Not only...but..., It's not just X, it's Y
- Before: "It's not just about the beat; it's part of the aggression"
- After: "The heavy beat adds to the aggressive tone"

**10. Rule of three overuse**
- Before: "innovation, inspiration, and industry insights"
- After: "The event includes talks and panels"

**11. Synonym cycling**
- Before: "The protagonist... The main character... The central figure... The hero..."
- After: "The protagonist faces challenges but eventually triumphs"

**12. False ranges**
- Before: "from the Big Bang to the cosmic web, from star birth to dark matter"
- After: "The book covers the Big Bang, star formation, and dark matter theories"

### Style Patterns

**13. Dash overuse**
Watch for repeated em dashes doing the work of commas, periods, colons, and parentheses. Preserve dashes when they fit the author's normal style and improve the sentence.

**14. Boldface overuse**
Remove mechanical bold emphasis on terms.

**15. Inline-header vertical lists**
- Before: "**Performance:** Enhanced through optimization"
- After: Prose combining the points when the list exists only for mechanical symmetry. Preserve lists that genuinely improve scanning.

**16. Title Case in headings**
- Before: "Strategic Negotiations And Global Partnerships"
- After: "Strategic negotiations and global partnerships" when sentence case matches the author or house style

**17. Emojis**
Remove decorative 🚀 💡 ✅ and similar flourishes when they are not characteristic of the author or format. Preserve intentional emoji use.

**18. Typography drift**
Do not change quote style merely to make text look more human. Preserve the typography expected by the author, format, or publishing system.

### Communication Patterns

**19. Chatbot artifacts**
Remove generic service-language such as "I hope this helps!", "Of course!", "Certainly!", or "Would you like..." when it is not a genuine part of the message. Do not ban ordinary closings the author actually uses.

**20. Knowledge-cutoff disclaimers**
Remove boilerplate such as "While specific details are limited..." or "based on available information..." when it contributes nothing. Preserve dates and caveats that genuinely bound the claim.

**21. Sycophantic tone**
Remove unearned praise such as "Great question!", "You're absolutely right!", or "That's an excellent point!" Preserve sincere acknowledgement when it serves the conversation.

### Filler and Hedging

**22. Filler phrases**
- "In order to" → "To"
- "Due to the fact that" → "Because"
- "At this point in time" → "Now"
- "has the ability to" → "can"
- "It is important to note that" → (delete)

**23. Excessive hedging**
- Before: "could potentially possibly be argued that it might have some effect"
- After: "may affect outcomes"

**24. Generic positive conclusions**
- Before: "The future looks bright. Exciting times lie ahead."
- After: "The company plans to open two more locations next year."

---

## The 14 Construction Patterns

Construction is how the piece is built, not how it is worded. For definitions, evidence levels, and fixes, read `reference/construction-patterns.md`. It distinguishes research findings from nonfiction adaptations and broader editorial heuristics.

Never inject synthetic humanity: fixes must surface something true. Ask when only the author knows; use an explicit placeholder only when the user wants a draft with gaps marked.

If an AI detector is used, compare matched text boundaries, formats, and window-level results. Treat its output as one diagnostic signal, never the editing objective or evidence of authorship. Do not add artefacts to chase a score.

---

## Output

1. The rewritten text (or, for reviews: verdict, triggered patterns with evidence, and what's already working so edits don't remove it)
2. Brief summary of changes made (optional)

## Reference

Surface patterns based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). Construction-pattern evidence and provenance are documented in `reference/construction-patterns.md`.
