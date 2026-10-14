///|
pub(all) enum SearchLimit {
  NodeBudget
  OperationBudget
} derive(Eq, Debug)

///|
pub extend SearchLimit with Eq::{equal, not_equal}

///|
pub extend SearchLimit with @debug.Debug::{to_repr}

///|
pub(all) enum SolveOutcome {
  Satisfiable(Witness)
  Unsatisfiable
  Unknown(SearchLimit)
}

///|
pub(all) struct SolveReport {
  outcome : SolveOutcome
  nodes : Int32
  operations : Int32
  maximum_depth : Int32
}

///|
pub struct SearchOptions {
  priv nodes : Int32
  priv operations : Int32
}

///|
pub fn SearchOptions::new(
  max_nodes~ : Int32 = 10000,
  max_operations~ : Int32 = 1000000,
) -> SearchOptions raise AllenError {
  if max_nodes < 0 || max_nodes > 1000000 {
    raise InvalidLimit("search nodes must be 0..1000000")
  }
  if max_operations < 0 || max_operations > 10000000 {
    raise InvalidLimit("search operations must be 0..10000000")
  }
  { nodes: max_nodes, operations: max_operations, }
}

///|
priv struct SearchState {
  mut nodes : Int32
  mut operations : Int32
  mut depth : Int32
}

///|
fn search_visit(
  alg : Algebra,
  net : Network,
  options : SearchOptions,
  state : SearchState,
  depth : Int32,
) -> SolveOutcome raise AllenError {
  if state.nodes >= options.nodes {
    return Unknown(NodeBudget)
  }
  state.nodes = state.nodes + 1
  if depth > state.depth {
    state.depth = depth
  }
  let remaining = options.operations - state.operations
  let report = propagate(alg, net, { operations: remaining, trace: 0, })
  state.operations = state.operations + report.operations
  match report.status {
    Contradiction => return Unsatisfiable
    PropagationLimit => return Unknown(OperationBudget)
    PathConsistent => ()
  }
  let narrowed = report.network
  let n = narrowed.size()
  let mut left = -1
  let mut right = -1
  let mut best = 14
  for i = 0; i < n; i = i + 1 {
    for j = i + 1; j < n; j = j + 1 {
      let count = narrowed.cells[i * n + j].size()
      if count > 1 && count < best {
        best = count
        left = i
        right = j
      }
    }
  }
  if left == -1 {
    return match realize_atomic(narrowed) {
      Some(w) => Satisfiable(w)
      None => Unsatisfiable
    }
  }
  for atom in narrowed.cells[left * n + right].items() {
    let cells = narrowed.cells.copy()
    cells[left * n + right] = RelSet::single(atom)
    cells[right * n + left] = RelSet::single(atom.converse())
    match
      search_visit(alg, with_cells(narrowed, cells), options, state, depth + 1) {
      Satisfiable(w) => return Satisfiable(w)
      Unknown(limit) => return Unknown(limit)
      Unsatisfiable => ()
    }
  }
  Unsatisfiable
}

///|
/// Finite complete branching, bounded globally. Exhaustion is never UNSAT.
pub fn solve(
  alg : Algebra,
  net : Network,
  options : SearchOptions,
) -> SolveReport raise AllenError {
  if net.size() > 24 {
    raise TooLarge(net.size())
  }
  let state = { nodes: 0, operations: 0, depth: 0, }
  let outcome = search_visit(alg, net, options, state, 0)
  {
    outcome,
    nodes: state.nodes,
    operations: state.operations,
    maximum_depth: state.depth,
  }
}
