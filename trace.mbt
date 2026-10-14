///|
/// Validate that a matrix has no empty domains and is closed under composition.
pub fn is_path_consistent(alg : Algebra, net : Network) -> Bool {
  let n = net.size()
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let set = net.cells[i * n + j]
      if set.is_empty() {
        return false
      }
      if set.converse() != net.cells[j * n + i] {
        return false
      }
      for k = 0; k < n; k = k + 1 {
        if !set.subset_of(
            alg.compose(net.cells[i * n + k], net.cells[k * n + j]),
          ) {
          return false
        }
      }
    }
  }
  true
}

///|
/// Replay a complete trace against its initial matrix, rejecting forged steps.
/// Truncated traces deliberately fail; their result may still be valid.
pub fn verify_trace(
  alg : Algebra,
  initial : Network,
  report : ClosureReport,
) -> Bool {
  if !report.trace_complete ||
    report.reduction_count != report.reductions.length() {
    return false
  }
  if initial.names != report.network.names {
    return false
  }
  let cells = initial.cells.copy()
  let n = initial.size()
  for step in report.reductions {
    let i = step.left
    let j = step.right
    let k = step.via
    if i < 0 || j < 0 || k < 0 || i >= n || j >= n || k >= n || i >= j {
      return false
    }
    if cells[i * n + j] != step.before {
      return false
    }
    let expected = step.before.intersect(
      alg.compose(cells[i * n + k], cells[k * n + j]),
    )
    if expected != step.after || expected == step.before {
      return false
    }
    cells[i * n + j] = expected
    cells[j * n + i] = expected.converse()
  }
  if cells != report.network.cells {
    return false
  }
  match report.status {
    PathConsistent => is_path_consistent(alg, report.network)
    Contradiction => cells.any(s => s.is_empty())
    PropagationLimit => report.network.is_refinement_of(initial)
  }
}
