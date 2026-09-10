---
name: writing-plainly
description: Rules for prose a person will read, including replies, PR text, review findings, plans, docs, and handoffs. Use when drafting any of those, when editing text for AI tells, or when another skill cites a rule number from here.
---

# Writing plainly

Write so the reader can act after the first sentence and stop whenever they have enough. Rule numbers are stable ids that other skills cite. A removed rule leaves a gap.

## Structure

1. **Lead with the answer.** Verdict, decision, or result first. Detail after, and only what the reader needs to act.
2. **One idea per paragraph, stated in its first sentence.** The reader should be able to read first sentences only.
3. **Prefer paragraphs to lists.** Use a list only for items that are parallel and would be read as a set.
4. **No inline-header lists.** A bold label plus colon that restates the line ("**Performance:** performance improved") is a tell. Convert to prose. A bold lead-in that names an item and is followed by new detail is fine.
5. **Drop empty sections.** Never write "None", "N/A", or a heading with nothing under it to complete a template.
6. **End on the last fact, decision, or ask.** No recap, no "in summary", no upbeat closer.
7. **Do not announce the point.** Delete "the key insight is", "it is important to note", "this matters because", and keep what follows.
8. **Say it once.** State a claim in one place and let it stand. Do not restate at the end of the section or in the conclusion.
9. **Follow the caller's format when there is one.** A required schema, template, or connector format wins over these rules. Fill it tersely and leave optional parts empty rather than padding them.

## Words

10. **Use the reader's words and the code's names.** Name the file, function, command, flag, error, and number. Define any other term or drop it.
11. **Prefer the plain word.** "use" not "utilize" or "leverage", "help" not "facilitate", "many" not "numerous", "if" not "in the event that".
12. **Say "is" and "has".** Not "serves as", "stands as", "boasts", "features", "offers".
13. **Cut AI vocabulary.** Additionally, crucial, delve, enhance, ensure, fostering, interplay, intricate, landscape, pivotal, robust, seamless, showcase, tapestry, testament, underscore, vibrant.
14. **Cut metaphor nouns.** Substrate, wedge, vector, primitive, harness, surface (as in "API surface"), scaffolding, paradigm, north star, flywheel, endgame. Use the concrete word: "base", "add", "way", "API".
15. **Say what it does, not how it feels.** "types that follow your schema" names a feeling. "a column rename fails the build" names the mechanism. If a sentence could appear unchanged in another project's docs, it says nothing about this one. Cut it.
16. **Cut adverbs, or use the number.** "significantly improves" becomes the measured delta. "runs quickly" becomes "is fast" or the time.
17. **Active voice.** "the loader parses the file", not "the file is parsed by the loader". Passive only when the actor is unknown or irrelevant.
18. **Hedge once, precisely.** "untested on Windows", not "could potentially possibly".
19. **No "not just X but Y", no forced triads, no false ranges.** State the point. Use the natural number of items. List topics instead of "from X to Y".
20. **Pick one name and repeat it.** Do not cycle synonyms to avoid repetition.
21. **No superficial -ing tails.** "…, highlighting the importance of testing" adds nothing. Delete or replace with a fact.
22. **Name the source or delete the claim.** Not "experts believe" or "it is widely known".
23. **Whole sentences.** No dropped articles, verbless fragments, arrows, or abbreviations the reader must decode. "Parser rejects bad date → exit 2" becomes "The parser rejects a bad date and exits with code 2."
24. **Split dense sentences.** If the reader must backtrack, break the sentence or drop a clause.
25. **No mannered prose.** No aphorisms, rhetorical fragments, personified code ("the plan holds it"), or figurative verbs ("rides along", "stands on"). Say the literal thing.

## Punctuation and format

26. **No em dashes.** Use a period or a comma. Not an en dash or a hyphen as a substitute either.
27. **Colons before a list or example only.** Not as a mid-sentence connector.
28. **Sentence-case headings** unless the repository uses another convention.
29. **Bold sparingly.** Not on every proper noun, acronym, or list item.
30. **No decorative emoji.** None in headings or bullets.
31. **Straight quotes.**

## Tone

32. **No chatbot phrases.** No "I hope this helps", "Let me know if", "Certainly", "Of course", "Great question", "You're absolutely right".
33. **No thanks, praise, or apology in work text.** Disagree plainly and give the evidence.
34. **No generic conclusions.** "The future looks bright" becomes a specific plan or fact, or nothing.
35. **Do not invent to sound human.** No manufactured anecdotes, opinions, asides, jokes, or roughness. If a fix needs a fact only the author has, ask.

## Applying the rules

When drafting, write the first sentence as the answer, then check the draft against rules 3 to 9 and skim for the words in 11 to 14.

When editing, read once for structure (1 to 9), once for wording (10 to 25), then ask "what still makes this read as generated?" and fix that. Preserve meaning, quotations, code, commands, links, identifiers, and data. Edit in place rather than regenerating.

A repository's own voice wins when editing its docs or filling its templates. A user's voice guide such as `speak-like-lachlan` overrides these rules where they differ.

## Example

Before:

> I've gone ahead and implemented a comprehensive fix that ensures the sync job is robust against transient network failures. It's worth noting that this not only improves reliability but also enhances observability. Let me know if you'd like any further changes!

After:

> The nightly sync no longer aborts on `ECONNRESET`. `fetchOrders` retries three times with backoff. I have not run it against the staging gateway.
