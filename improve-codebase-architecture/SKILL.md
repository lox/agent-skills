---
name: improve-codebase-architecture
description: Finds evidence-backed deepening opportunities that improve module leverage, locality, and testability. Use when asked to improve architecture, consolidate tightly coupled modules, reduce shallow abstractions, or explore a selected interface design.
---

# Improve codebase architecture

Find architectural friction and propose deepening opportunities: refactors that turn shallow modules into deep ones. The aim is code that is easier to test and easier for people and agents to navigate.

## Glossary

Use these terms consistently when reasoning about the architecture. Full definitions are in [reference/language.md](reference/language.md).

- **Module**: anything with an interface and an implementation (function, class, package, slice).
- **Interface**: everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation**: the code inside.
- **Depth**: leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam**: where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter**: a concrete thing satisfying an interface at a seam.
- **Leverage**: what callers get from depth.
- **Locality**: what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [reference/language.md](reference/language.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

When relevant engineering plans exist, use them to identify important seams, settled decisions, and codebase constraints. Do not assume every repository has `docs/plans/` or require a plan for architecture analysis.

## Process

### 1. Explore

Read relevant engineering plans first when they exist. Prefer recent, active, and similar-domain plans when there are many.

Use the plan docs the same way `drafting-plans` does:

- Treat an existing plan as the sequencing source of truth when the architecture question continues that work.
- Read relevant code, docs, schemas, runtime config, or issue/PR context before naming interfaces, examples, commands, or validation.
- Verify cheap drift-prone facts against the current repo before treating a plan statement as current state.
- Notice plan status (`proposed`, `active`, `paused`, `landed`, `superseded`) and avoid re-litigating landed or superseded decisions unless current code friction makes the revisit worthwhile.
- Pull forward the plan's goals, non-goals, invariants, delivery slices, verification strategy, and open questions when evaluating architecture candidates.

Inspect the codebase with the host's normal semantic search, exact search, and file-reading tools. Explore organically and note where understanding creates friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

#### Focus exploration with historical evidence

When the repository has usable Git history and `scc` 4 or newer is available, use change hotspots and temporal coupling to decide where to start reading. Follow [reference/hotspots.md](reference/hotspots.md) for the commands and how to read the results. Hotspots and coupling are prioritization evidence only: present a candidate when code inspection explains the measured signal as friction at a seam, missing locality, or shallow-module overhead, and continue without the analysis if the tools or history are unavailable.

### 2. Present candidates

Present a numbered list of deepening opportunities, written per `writing-plainly`. Each candidate is two or three short paragraphs, not a set of labeled fields, and covers:

- the files or modules involved
- the friction you observed, with hotspot or coupling evidence when it informed the pick; keep measured facts separate from interpretation
- relevant `docs/plans/` context, including conflicts or open questions, when it matters
- what would change, in plain words
- what gets easier: which changes land in one place, which bugs stop spreading, which tests become possible through the new interface
- the smallest boring, useful first step if the user chooses to explore it

The glossary is for your reasoning. In the candidate text, use the plan's names for the product or system domain when plans exist (if a plan says "Order intake", say "Order intake"), and describe the architecture in the reader's terms; use "seam", "locality", or "leverage" only where the reader already uses them or you define them in passing.

If a candidate contradicts an existing plan decision, include it only when the friction is real enough to warrant revisiting the plan, and say so plainly (for example: "contradicts `docs/plans/example.md`, but worth reopening because…"). Don't list every theoretical refactor a plan rules out.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them: constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

When historical evidence informed the candidate, inspect `--coupling-for` results and representative shared commits during this loop. Decide whether the coupled files express one responsibility that lacks an owner or merely healthy coordination. Do not invent a combined architecture score; the code-level explanation is the decision evidence.

Update an existing plan only when the user asked to revise the plan or the architecture work is part of an authorized implementation workflow. Otherwise recommend the durable update in the handoff.

As decisions crystallize:

- **Naming a deepened module after a concept that belongs in an existing plan?** Update the relevant `docs/plans/` document with the term, ownership seam, or decision.
- **Sharpening a fuzzy term during the conversation?** Record the clarified terminology in the relevant plan when it will help future architecture work.
- **Changing scope, interface shape, risks, sequencing, or validation?** Update the plan in the same pass. Treat the plan as the working map, not a changelog.
- **Resolving an open question?** Move it to resolved decisions or adjust goals/non-goals and delivery slices. Leave only genuinely unresolved questions.
- **Adding findings from the architecture review?** Fold them into the plan's scope, approach, risks, or slices, as `drafting-plans` does. Do not add a detached critique or "Key Learnings" section.
- **Updating a plan with YAML frontmatter?** Update `last_reviewed` after substantive revisions or revalidation, and change `status` only for lifecycle changes.
- **User rejects the candidate with a load-bearing reason?** Offer to record the reason in the relevant plan so future architecture reviews don't re-suggest it. Only offer when the reason would actually be needed by a future explorer; skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **No relevant plan exists, but the candidate becomes real work?** Offer to draft a new `docs/plans/` plan using the repository's plan conventions. Do not create one just to record a casual idea.
- **Want to explore alternative interfaces for the deepened module?** See [reference/interface-design.md](reference/interface-design.md).
