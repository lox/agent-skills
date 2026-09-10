# Hotspot and coupling analysis

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

