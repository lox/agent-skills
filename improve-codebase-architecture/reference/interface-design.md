# Interface Design

When the user wants to explore alternative interfaces for a chosen deepening candidate, use this "Design It Twice" workflow (Ousterhout) — the first idea is unlikely to be the best.

Use the vocabulary in [language.md](language.md) — **module**, **interface**, **seam**, **adapter**, **leverage**.

## Process

### 1. Frame the problem space

Write a concise explanation of the problem space for the chosen candidate:

- The constraints any new interface would need to satisfy
- The dependencies it would rely on, and which category they fall into (see [deepening.md](deepening.md))
- A rough illustrative code sketch to ground the constraints — not a proposal, just a way to make the constraints concrete

Use this frame as the common brief for each design.

### 2. Generate distinct designs

Generate at least three meaningfully different interfaces sequentially by default. If the user explicitly requests delegation and the host supports it, independent designs may be delegated in parallel.

Use the same technical brief for each design: file paths, coupling details, dependency category from [deepening.md](deepening.md), what sits behind the seam, and one different design constraint:

- Design 1: "Minimize the interface — aim for 1–3 entry points max. Maximise leverage per entry point."
- Design 2: "Maximise flexibility — support many use cases and extension."
- Design 3: "Optimise for the most common caller — make the default case trivial."
- Design 4 (if applicable): "Design around ports & adapters for cross-seam dependencies."

Include both [language.md](language.md) vocabulary and relevant plan vocabulary in the brief so each design names things consistently.

For each design, provide:

1. Interface (types, methods, params — plus invariants, ordering, error modes)
2. Usage example showing how callers use it
3. What the implementation hides behind the seam
4. Dependency strategy and adapters (see [deepening.md](deepening.md))
5. Trade-offs — where leverage is high, where it's thin

### 3. Present and compare

Present designs sequentially so the user can absorb each one, then compare them in prose. Contrast by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**.

After comparing, give your own recommendation: which design you think is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not a menu.
