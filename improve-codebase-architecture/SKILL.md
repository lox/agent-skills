---
name: improve-codebase-architecture
description: Finds evidence-backed deepening opportunities that improve module leverage, locality, and testability. Use when asked to improve architecture, consolidate tightly coupled modules, reduce shallow abstractions, or explore a selected interface design.
---

# Improve codebase architecture

Find where the code fights its readers and propose refactors that turn shallow modules into deep ones, so that changes land in one place and tests can run through a real interface.

## Vocabulary for your reasoning

Full definitions are in [reference/language.md](reference/language.md). A module is anything with an interface and an implementation. Its interface is everything a caller must know, not just the type signature: types, invariants, error modes, ordering, config. A module is deep when a small interface hides a lot of behaviour and shallow when the interface is nearly as complex as the code behind it. A seam is where an interface lives and behaviour can be swapped without editing in place; an adapter is a concrete thing satisfying it. Depth gives callers leverage and gives maintainers locality: changes, bugs, and knowledge concentrated in one place.

Two tests drive the analysis. The deletion test: imagine removing the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep. And the seam test: one adapter is a hypothetical seam, two adapters are a real one. The interface is the test surface.

Use these words when thinking. In text for the user, follow the rule in the candidates section.

## Explore

If the repository has engineering plans, read the relevant ones first as `drafting-plans` describes: treat an active plan as the sequencing source of truth, check drift-prone facts against the code, and do not reopen landed or superseded decisions unless current friction justifies it. Not every repository has `docs/plans/`; do not require one.

Read the code with the host's search and file tools and note where understanding is expensive. Where does one concept require bouncing between many small modules? Which modules are shallow? Where were pure functions extracted for testability while the real bugs hide in how they are called? Where does coupled code leak across its seams? What is untested or untestable through its current interface? Apply the deletion test to anything that looks shallow; you want the cases where deleting would concentrate complexity rather than move it.

When the repository has usable Git history and `scc` 4 or newer, use change hotspots and temporal coupling to decide where to start reading. [reference/hotspots.md](reference/hotspots.md) has the commands and how to read them. Hotspots only prioritize. Present a candidate only when reading the code explains the measured signal as a seam problem, missing locality, or shallow-module overhead, and continue without the analysis when the tools or history are unavailable.

## Present candidates

Give a numbered list of deepening opportunities, written per `writing-plainly`. Each is two or three short paragraphs, not labeled fields, covering the files or modules involved; the friction you saw, with hotspot or coupling numbers when they informed the pick and kept separate from your interpretation; relevant plan context when it matters; what would change, in plain words; what gets easier (which changes land in one place, which bugs stop spreading, which tests become possible); and the smallest boring first step.

Use the plan's names for the domain when plans exist. If a plan says "Order intake", say "Order intake". Describe the architecture in the reader's terms and use "seam", "locality", or "leverage" only where the reader already does or you define it in passing.

If a candidate contradicts a plan decision, include it only when the friction is worth reopening the plan, and say so ("contradicts `docs/plans/example.md`, but worth reopening because..."). Do not list refactors a plan has ruled out.

Do not propose interfaces yet. Ask which candidate the user wants to explore.

## Grilling loop

Once the user picks one, walk the design with them: constraints, dependencies, the shape of the deepened module, what sits behind the seam, which tests survive. When history informed the pick, read the `--coupling-for` partners and a few shared commits and decide whether they are one responsibility without an owner or ordinary coordination. The code-level explanation is the evidence; do not invent a combined score.

Update an existing plan only when the user asked for plan revisions or the work is part of an authorized implementation. Otherwise recommend the update in the handoff. When you do update, fold the results into the plan as `drafting-plans` does: record a new or sharpened term, a changed scope, interface, risk, order, or validation, and a resolved question in the place it belongs; do not add a detached critique or "Key Learnings" section. For a plan with YAML frontmatter, set `last_reviewed` after a substantive revision and change `status` only for a lifecycle change.

Offer to record a rejection in the plan only when the reason is load-bearing and a future reviewer would need it; skip "not now" and the self-evident. Offer to draft a new plan under the repository's conventions only when a candidate becomes real work. For alternative interface shapes for the deepened module, see [reference/interface-design.md](reference/interface-design.md).
