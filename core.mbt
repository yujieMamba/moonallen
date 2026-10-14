///|
pub(all) struct UnsatCore {
  constraints : Array[Constraint]
  minimal : Bool
  checks : Int32
  unresolved_checks : Int32
}

///|
pub(all) enum CoreOutcome {
  ConflictCore(UnsatCore)
  SourceSatisfiable(Witness)
  CoreUnknown(SearchLimit)
}

///|
/// Extract a subset of original source constraints, not a shortest contradiction.
/// A core remains UNSAT throughout; minimal is true only after all deletion checks.
pub fn explain_unsat(
  alg : Algebra,
  net : Network,
  options : SearchOptions,
  max_checks~ : Int32 = 256,
) -> CoreOutcome raise AllenError {
  if max_checks < 1 || max_checks > 4097 {
    raise InvalidLimit("core checks must be 1..4097")
  }
  let mut retained = net.sources.copy()
  let initial = Network::from_constraints(net.names, retained)
  match solve(alg, initial, options).outcome {
    Satisfiable(w) => return SourceSatisfiable(w)
    Unknown(limit) => return CoreUnknown(limit)
    Unsatisfiable => ()
  }
  let mut checks = 1
  let mut unresolved = 0
  let mut cursor = 0
  while cursor < retained.length() && checks < max_checks {
    let trial_sources : Array[Constraint] = []
    for i = 0; i < retained.length(); i = i + 1 {
      if i != cursor {
        trial_sources.push(retained[i])
      }
    }
    let trial = Network::from_constraints(net.names, trial_sources)
    checks = checks + 1
    match solve(alg, trial, options).outcome {
      Unsatisfiable => retained = trial_sources
      Satisfiable(_) => cursor = cursor + 1
      Unknown(_) => {
        unresolved = unresolved + 1
        cursor = cursor + 1
      }
    }
  }
  ConflictCore({
    constraints: retained,
    minimal: cursor == retained.length() && unresolved == 0,
    checks,
    unresolved_checks: unresolved,
  })
}

///|
/// Validate UNSAT for a reported core; budget exhaustion returns Unknown.
pub fn verify_core(
  alg : Algebra,
  names : Array[String],
  core : UnsatCore,
  options : SearchOptions,
) -> SolveReport raise AllenError {
  solve(alg, Network::from_constraints(names, core.constraints), options)
}
