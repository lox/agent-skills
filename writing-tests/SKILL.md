---
name: writing-tests
description: Writes and maintains meaningful tests with minimal machinery. Use when deciding whether to add tests, investigating failures, or changing assertions, snapshots, fixtures, mocks, skips, or tolerances.
---

# Writing tests

Keep the tests that catch regressions, not the most tests. A change does not always need a new test.

## Before adding a test

Look at existing coverage first. Name the observable contract or realistic fault the new test protects, and extend an existing test when that is clearer. Do not add tests that restate the implementation, such as asserting a config value as a literal without checking any contract, and do not add cases for coverage, symmetry, or every helper and branch. Test through a stable interface with the fewest fixtures and mocks that work, and assert the outcome, not the mock setup. Take expected values from requirements, contracts, known examples, or an independent oracle, never from a copy of the implementation.

## When a test fails

Decide whether the implementation, the test, or the environment is wrong before touching the expectation. Observed output alone does not justify changing it. Change an expectation only for an intended contract change or evidence the old one was wrong. Replace refactor-sensitive assertions while keeping the required behavior covered. Never weaken an assertion, regenerate a snapshot, widen a tolerance, skip a case, or delete a test to get green. For a bug fix, show the reproducer failing before the fix and passing after when practical.

## When removing or merging tests

Delete or merge only when the remaining tests protect the same contract and failure mode. Shared line coverage is not enough. Keep distinct rejection, security, persistence, concurrency, compatibility, boundary, and numerical guarantees; small tests for rare cases are often the valuable ones. A characterisation test records existing behavior, not correctness. Do not silently replace a specification with observed output.

## When to stop

Run the tests that cover the change and the repository's required checks. Once they pass, test more only for new changes, failures, or a specific unresolved concern. Do not add per-test reports or mutation testing unless asked.
