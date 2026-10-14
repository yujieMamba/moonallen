# Attribution and implementation provenance

- **Project:** MoonAllen, original MoonBit implementation, copyright 2026
  yujieMamba, Apache-2.0. Not a source-code port of another solver.
- **Theory:** James F. Allen, “Maintaining Knowledge about Temporal Intervals”,
  Communications of the ACM 26(11), 832–843 (1983),
  https://doi.org/10.1145/182.358434 . Reference is to the mathematical relation
  definitions and qualitative constraint propagation, not a copied paper/table.
- **Runtime/standard library:** moonbitlang/core (Apache-2.0),
  https://github.com/moonbitlang/core . Uses standard collections, debug support,
  JSON parsing/printing and built-in assertions. No vendored core code.
- **Tests and examples:** synthetic intervals and deterministic generators authored
  for this repository. Composition is calculated by project code; the independent
  oracle is separately authored endpoint logic. No third-party fixtures/assets.
- **Comparison only:** moon_egg, moon-shapefile, ac-library-mbt,
  moonbit-slotplan, moonbitemporal and temporal were read to establish boundaries.
  Their code, data and interfaces were not copied into this repository. Exact
  versions, licenses and evidence are recorded in the duplication document.
- **AI assistance:** see AI-USE.md. Attribution above is not an assertion of formal
  verification, benchmark superiority or endorsement by the theory author.
