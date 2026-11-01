# Changelog

## 0.1.1 — 2026-11-01

- Regenerate public interfaces with moonc 0.10.18 (canonical Int32 names).
- Require moonc >= 0.10.16 in CI and document the verified toolchain.
- Preserve the existing reasoning API and runtime behavior.

## 0.1.0 — 2026-10-14

- Proper intervals, all 13 Allen relations, validated bitsets and exact composition.
- Immutable named constraints, bounded propagation and replayable reduction traces.
- Complete bounded scenario search with exact atomic endpoint realization;
  explicit SAT/UNSAT/Unknown outcomes and independently checkable witnesses.
- Possibility/entailment queries, deletion-based source conflict cores,
  observations, named merges, matrix views, renaming and components.
- Bounded DSL/JSON interchange, separate snapshots and evidence exports,
  stable text/DOT/diagnostic reports, and three runnable downstream workflows.
- Exhaustive mask and small-network oracle tests, malformed/resource regressions,
  four-target clean-runner CI and Apache-2.0 provenance documentation.

- Release validation uses MoonBit 2026-10-12: explicit Int32 interfaces and non-deprecated JSON conversions.
