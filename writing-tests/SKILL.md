---
name: writing-tests
description: Writes and maintains meaningful tests with minimal machinery. Use when deciding whether to add tests, investigating failures, or changing assertions, snapshots, fixtures, mocks, skips, or tolerances.
---

# Writing Tests

Preserve useful regression protection, not test volume. Verification does not always require new tests.

## Before adding

- Inspect existing coverage. Identify the distinct observable contract or realistic fault the test should protect against; extend an existing test when clearer.
- Do not write implementation-mirroring tests for reversible, low-impact changes, or add cases merely for coverage, symmetry, or every helper and branch.
- Test through a stable interface with minimal fixtures and mocks. Assert meaningful outcomes, not mock setup or incidental internals.
- Derive expected results from requirements, established contracts, known examples, or an independent oracle—not a copy of the implementation.

## When tests fail

- Determine whether the implementation, test, or environment is wrong before editing expectations. Observed output alone does not justify a change.
- Change expectations only for an intended contract change or evidence the old expectation was incorrect. Replace refactor-sensitive assertions while preserving required behaviour.
- Never weaken assertions, regenerate snapshots, broaden tolerances, skip cases, or delete tests merely to get green checks.
- For bug fixes, demonstrate the reproducer fails against the buggy implementation and passes with the fix where practical.

## When simplifying

- Delete or consolidate tests only when retained tests protect the same required contract and failure mode. Shared line coverage is insufficient evidence.
- Preserve distinct rejection, security, persistence, concurrency, compatibility, boundary, and numerical guarantees. Small tests and rare cases can be valuable.
- Characterisation tests establish existing behaviour, not correctness. Do not silently replace a specification with observed output.

## Stop

Run tests appropriate to the change and complete required checks. Once those pass, broaden or repeat testing only for new changes, failures, or specific unresolved concerns. No mandatory per-test reports or mutation-testing framework.
