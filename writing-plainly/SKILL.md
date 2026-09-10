---
name: writing-plainly
description: Sets the defaults for drafting prose a person will read, including PR bodies, review findings, PR replies, plans, docs, walkthroughs, and chat replies. Use before writing any of those, or when another skill points here for its output style.
---

# Writing plainly

Write for the reader doing the next task. They should be able to act after the first sentence and stop reading whenever they have enough.

## Defaults

- Lead with the answer, verdict, or decision. Put supporting detail after it, and only the detail the reader needs to act.
- Use the reader's words and the code's names. Name files, functions, commands, flags, and numbers. Define any other term or drop it.
- Short sentences, active voice, concrete nouns. One idea per paragraph, its point in the first sentence.
- Prefer paragraphs. Use a list only for items that are genuinely parallel, and never put a bold label on every item.
- Say "is" and "has". Not "serves as", "leverages", "surfaces", "ensures", "enables".
- State a claim once and let it stand. Do not announce it: no "the key insight is", "it is important to note", "this matters because".
- Avoid "not just X but Y", reflexive triads, and decorative emoji.
- Hedge once and precisely ("untested on Windows"), not in stacks ("could potentially possibly").
- No greetings, thanks, praise, apologies, or "hope this helps". Disagree plainly and give the evidence.
- Fill only sections that have content. Never write "None", "N/A", or an empty heading to complete a template; drop the section.
- Sentence-case headings unless the repository uses another convention.
- End on the last fact, decision, or ask. No summary that repeats the body, no upbeat closer.

## Example

Before:

> I've gone ahead and implemented a comprehensive fix that ensures the sync job is robust against transient network failures. It's worth noting that this not only improves reliability but also enhances observability. Let me know if you'd like any further changes!

After:

> The nightly sync no longer aborts on `ECONNRESET`: `fetchOrders` retries three times with backoff. I have not run it against the staging gateway.

Match a repository's own voice when editing its docs or following its templates. When the user has a voice guide such as `speak-like-lachlan`, that guide overrides these defaults.
