# Construction Patterns (25-38)

AI writing patterns in how a piece is built, not how it is worded. Derived from StoryScope ([arXiv 2604.03136](https://arxiv.org/abs/2604.03136)), which found structural features still identify AI text at ~94% accuracy after the style has been edited clean. Adapted from fiction research to nonfiction: treat as editorial heuristics, never as a detector.

Work from a structural template of the piece, not the prose. For each section note: what it does (setup, evidence, resolution, lesson), where the thesis appears, what tension is raised and whether it resolves, time structure, and every author/reader appearance.

## Thematic over-determination

**25. Thesis over-restatement**
The point is re-stated at the end of every section, and again in the conclusion. Humans trust the reader to remember.
- Fix: cut section-ending recaps; let one strong statement carry.

**26. Explicit significance labeling**
"The key insight is", "This matters because", "The important thing to understand". Humans let the material land and move on.
- Fix: delete the label, keep the material. If the material can't carry the point alone, the problem is the material.

**27. Total thematic unity**
Every paragraph serves the thesis; nothing is included just because it's interesting or true. Human writing has parallel material: asides that relate to the topic without being absorbed into the argument.
- Fix: can't be faked. Ask the author what they cut, or what almost derailed the work.

## Tidy resolution

**28. Every tension resolved**
Objections raised only to be immediately answered; tradeoffs stated then dissolved. Humans leave things standing: "this is the right call and it still annoys me".
- Fix: find the strongest objection and un-answer it, or say honestly why the answer is partial.

**29. Uniform intensity**
Every section has the same weight and stakes; nothing escalates, nothing is throwaway.
- Fix: compress the low-stakes sections hard so the piece builds toward the part that matters.

## Structural uniformity

**30. Uniform section shape**
Every section runs problem → explanation → lesson at similar length under parallel headings.
- Fix: vary deliberately. Let one section be two sentences. Merge sections that exist only for symmetry.

**31. Front-loaded revelation everywhere**
The intro states the conclusion, every section opens with its point, nothing is discovered en route. A thesis-early opening is fine; the tell is when no part of the piece withholds anything.
- Fix: pick one thread (usually the narrative of what happened) and tell it in the order it was experienced, including the wrong first theory.

**32. Strictly linear chronology**
The narrative runs front to back with no time jumps. Humans reorder: open mid-incident, flash back, jump to the postmortem.
- Fix: consider opening in medias res on the most concrete moment, then backfilling.

## Reader and author presence (absence is the tell)

**33. No direct reader address**
Humans address the reader 4x more than AI, which writes as though no one is watching.
- Fix: address the reader where they'd genuinely object or recognise themselves ("you've probably shipped this bug").

**34. No authorial presence**
No "I", no owned judgment calls, no doubt, no account of what the author got wrong first.
- Fix: restore first person at the points of judgment and error. "We assumed X; that was wrong" is structural humanity.

**35. Emotion by label, not by detail**
Feelings named abstractly ("this was frustrating") rather than shown through specifics.
- Fix: replace the label with the detail that produced it ("the page went off at 3am, again").

## Ambivalence (absence is the tell)

**36. Polarized or neutralized verdicts**
AI verdicts are clean (X good, Y bad) or evenly balanced (pros and cons, both valid). Human verdicts are mixed: committed but uncomfortable.
- Fix: only the author knows their real position. Ask, or flag the section as needing a genuine opinion.

## Convergence

**37. Template familiarity**
The piece has the default AI arc: hook, three tidy sections, "What we learned", callback ending. AI writing clusters structurally; human writing is rarer and more varied.
- Fix: compare against the author's other work if available. If the skeleton repeats, restructure around the piece's own strongest material.

**38. Over-integrated ending**
The ending resolves every thread, restates the thesis, and closes on an upbeat generalization. Human endings exit on a specific: an image, an open question, a dry observation.
- Fix: end one beat earlier than feels complete.

## What not to do

Never inject synthetic humanity. No fake anecdotes, invented ambivalence, or decorative asides the author doesn't hold. Every fix must surface something true that the drafting process suppressed: a real tangent, a real doubt, a real opinion. Where a fix requires facts only the author has, ask instead of inventing, or leave a specific placeholder: `TODO: what did you actually try first here?`

Structure serves the piece. A changelog entry or reference doc is allowed to be tidy and linear; don't force war stories into it.
