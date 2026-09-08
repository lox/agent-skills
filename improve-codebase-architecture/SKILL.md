---
name: improve-codebase-architecture
description: Finds evidence-backed deepening opportunities that improve module leverage, locality, and testability. Use when asked to improve architecture, consolidate tightly coupled modules, reduce shallow abstractions, or explore a selected interface design.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Glossary

Use these terms consistently in architecture suggestions. Full definitions are in [reference/language.md](reference/language.md).

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated in one place.

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
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

#### Focus exploration with historical evidence

When the repository has meaningful Git history and `scc` 4 or newer is available, use hotspots to prioritize where semantic inspection starts. This supplements organic exploration; it does not replace it or prevent candidates elsewhere.

Check that history is usable and resolve `scc` before relying on it:

```bash
command -v jq
git rev-parse --is-shallow-repository
if command -v scc >/dev/null; then
  scc --version
elif command -v mise >/dev/null; then
  mise exec aqua:boyter/scc@4.0.0 -- scc --version
fi
```

If `scc` is not directly installed but mise is available, replace the leading `scc` in the commands below with `mise exec aqua:boyter/scc@4.0.0 -- scc`; this installs into mise's cache without changing project or global mise configuration. If neither route provides `scc` 4 or newer, or `jq` is unavailable, continue without this analysis rather than blocking the review.

If the checkout is shallow, fetch the full history before drawing conclusions when possible. If history cannot be completed, state the limitation and treat the results as recent-history evidence only.

Compare a durable and a recent window, limiting the JSON shown to the highest-ranked files:

```bash
scc --no-config --hotspots --depth 500 --format json . | jq '{window, files: .files[:10]}'
scc --no-config --hotspots --depth 50 --format json . | jq '{window, files: .files[:10]}'
```

Interpret the overlap before reading the top few credible hotspots:

- High in both windows suggests persistent, active friction.
- High only in the durable window may be historically central but stable now.
- High only in the recent window may be emerging friction, a migration, or temporary feature work.
- A low score does not prove safety; rarely changed code can still contain serious architectural problems.

For a credible hotspot, inspect temporal coupling to discover the actual change unit and hidden blast radius:

```bash
scc --no-config --coupling-for path/to/file --coupling-weighted --depth 500 --format json . | jq '{window, target, targetCommits, partners: .partners[:10]}'
```

Weighted JSON is ordered by the weighted ranking, but its displayed coupling fields are raw values. Inspect representative shared commits and the coupled files before interpreting the relationship. Classify expected coupling such as implementation/tests, schemas/generated output, or documentation before treating it as architecture friction.

Use these metrics only as prioritization evidence:

- A hotspot is not a defect and is not, by itself, a reason to split a file.
- Change coupling is not, by itself, a reason to combine modules.
- Formatting, vendoring, generated files, broad migrations, and commit practices can distort history.
- Present a candidate only when code inspection explains the measured signal as real friction at a seam, missing locality, or shallow-module overhead.

### 2. Present candidates

Present a numbered list of deepening opportunities. For each candidate:

- **Files** — which files/modules are involved
- **Evidence** — observed code friction plus relevant hotspot/coupling evidence and rejected noise; separate measured facts from interpretation
- **Plan context** — relevant `docs/plans/` references, including conflicts or open questions when they matter
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and also in how tests and plan verification would improve
- **First slice** — the smallest boring, useful step if the user chooses to explore it

**Use plan vocabulary for the product or system domain when plans exist, and [reference/language.md](reference/language.md) vocabulary for the architecture.** If plans define a concept such as "Order intake," use that name consistently instead of falling back to incidental implementation names.

**Plan conflicts**: if a candidate contradicts an existing plan decision, only surface it when the friction is real enough to warrant revisiting the plan. Mark it clearly (e.g. _"contradicts `docs/plans/example.md` — but worth reopening because…"_). Don't list every theoretical refactor a plan rules out.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

When historical evidence informed the candidate, inspect `--coupling-for` results and representative shared commits during this loop. Decide whether the coupled files express one responsibility that lacks an owner or merely healthy coordination. Do not invent a combined architecture score; the code-level explanation is the decision evidence.

Update an existing plan only when the user asked to revise the plan or the architecture work is part of an authorized implementation workflow. Otherwise recommend the durable update in the handoff.

As decisions crystallize:

- **Naming a deepened module after a concept that belongs in an existing plan?** Update the relevant `docs/plans/` document with the term, ownership seam, or decision.
- **Sharpening a fuzzy term during the conversation?** Record the clarified terminology in the relevant plan when it will help future architecture work.
- **Changing scope, interface shape, risks, sequencing, or validation?** Update the plan in the same pass. Treat the plan as the working map, not a changelog.
- **Resolving an open question?** Move it to resolved decisions or adjust goals/non-goals and delivery slices. Leave only genuinely unresolved questions.
- **Adding material findings from the architecture review?** Prefer a concise `Key Learnings From Pressure-Testing` or existing equivalent section over a detached critique.
- **Updating a plan with YAML frontmatter?** Update `last_reviewed` after material revisions or revalidation, and change `status` only for lifecycle changes.
- **User rejects the candidate with a load-bearing reason?** Offer to record the reason in the relevant plan so future architecture reviews don't re-suggest it. Only offer when the reason would actually be needed by a future explorer — skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **No relevant plan exists, but the candidate becomes real work?** Offer to draft a new `docs/plans/` plan using the repository's plan conventions. Do not create one just to record a casual idea.
- **Want to explore alternative interfaces for the deepened module?** See [reference/interface-design.md](reference/interface-design.md).
