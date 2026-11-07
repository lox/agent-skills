---
name: improve-codebase-architecture
description: Finds evidence-backed deepening opportunities that improve module leverage, locality, and testability. Use when asked to improve architecture, prioritize refactoring in an unfamiliar codebase, investigate code hotspots or change coupling, consolidate tightly coupled modules, reduce shallow abstractions, or explore a selected interface design.
---

# Improve Codebase Architecture

Find **deepening opportunities**: refactors that hide more useful behaviour behind a simpler interface. Focus on testability and keeping related knowledge together, not abstract cleanliness.

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

## Evidence discipline

Every candidate needs file-level evidence of friction in current code:

- Repeated co-change whose current files spread one responsibility across modules.
- A cross-module bug whose underlying design problem remains.
- Tests that mock internals, break on refactor, or cannot exercise behaviour through the interface.
- Invariants, ordering constraints, or configuration facts each caller must independently get right.

Read the implementation, callers, and tests before accepting historical signals or plan claims. Separate measurements from interpretation. Drop candidates without current-code corroboration.

Do not propose single-adapter seams with nothing varying, file splits for size alone, move/rename-only refactors, or a new interface as complicated as what it hides. Preserve distinct regression contracts when moving tests; new interface tests alone do not justify deleting old ones (see [reference/deepening.md](reference/deepening.md)).

## Process

### 1. Scope and explore

Start with the named module or pain point. Otherwise use history to prioritize exploration and widen the search when changes are scattered. This is targeted discovery, not an exhaustive audit.

Read relevant plans or ADRs when present. Treat settled decisions as constraints unless current friction warrants reopening them. Do not require a plan.

Use the host's search and file-reading tools. Delegate bounded subsystem exploration only when useful and permitted by the host's delegation rules; do not require subagents or named tools.

Look for:

- One concept scattered across many modules.
- Shallow interfaces that impose nearly as much complexity as they hide.
- Pure functions extracted for testing while bugs remain in their orchestration.
- Coupled modules leaking knowledge across seams.
- Behaviour that cannot be tested through the current interface.

Apply the deletion test: does removing a module eliminate needless complexity or scatter useful implementation into its callers?

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

If `scc` is absent but mise is available, replace the leading `scc` below with `mise exec aqua:boyter/scc@4.0.0 -- scc`. This installs into mise's cache without changing project or global configuration. If neither route provides `scc` 4 or newer, or `jq` is unavailable, continue without these reports. Git history remains a change-frequency lead, not an equivalent hotspot score.

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

- Hotspot scores combine approximate complexity at `HEAD` with commit frequency and omit uncommitted work. They are normalized within each run; do not compare raw scores across windows, repositories, or languages.
- A hotspot is not a defect and is not, by itself, a reason to split a file.
- Change coupling is not, by itself, a reason to combine modules.
- Formatting, vendoring, generated files, broad migrations, and commit practices can distort history.
- Present a candidate only when code inspection explains the measured signal as real friction at a seam, missing locality, or shallow-module overhead.

### 2. Present candidates

Present a short ranked list. For each candidate include:

- **Files** — which files/modules are involved
- **Evidence** — observed code friction plus relevant hotspot/coupling evidence and rejected noise; separate measured facts from interpretation
- **Plan context** — relevant `docs/plans/` references, including conflicts or open questions when they matter
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and also in how tests and plan verification would improve
- **First slice** — the smallest boring, useful step if the user chooses to explore it

Use the architecture vocabulary above. When plans define product or system terms, use those terms too.

Flag any settled decision worth reopening and the current evidence for doing so. For a high-stakes or contested candidate, seek a read-only expert review when available and permitted by the host. Resolve unsupported claims before presenting.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### 3. Design the chosen candidate

After the user chooses, work through constraints, dependencies, interface alternatives, and test migration. Use [reference/deepening.md](reference/deepening.md) for dependencies and tests, and [reference/interface-design.md](reference/interface-design.md) to compare designs. Pressure-test the recommendation against the strongest alternative, using a read-only advisor when available and permitted.

When historical evidence informed the candidate, inspect `--coupling-for` results and representative shared commits during this loop. Decide whether the coupled files express one responsibility that lacks an owner or merely healthy coordination. Do not invent a combined architecture score; the code-level explanation is the decision evidence.

Record decisions only within an authorized plan-update or implementation workflow; otherwise recommend the update. Offer to record a durable reason for rejecting a candidate so future reviews do not repeat it. Do not create a plan for a casual idea or record temporary preferences as constraints.
