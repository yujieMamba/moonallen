///|
pub(all) enum ClosureStatus {
  PathConsistent
  Contradiction
  PropagationLimit
} derive(Eq, Debug)

///|
pub extend ClosureStatus with Eq::{equal, not_equal}

///|
pub extend ClosureStatus with @debug.Debug::{to_repr}

///|
pub(all) struct Reduction {
  left : Int
  right : Int
  via : Int
  before : RelSet
  after : RelSet
}

///|
pub(all) struct Conflict {
  left : String
  right : String
  via : String?
}

///|
pub(all) struct ClosureReport {
  status : ClosureStatus
  network : Network
  operations : Int
  reductions : Array[Reduction]
  reduction_count : Int
  trace_complete : Bool
  conflict : Conflict?
}

///|
pub struct PropagationOptions {
  priv operations : Int
  priv trace : Int
}

///|
pub fn PropagationOptions::new(
  max_operations? : Int = 1000000,
  max_trace? : Int = 10000,
) -> PropagationOptions raise AllenError {
  if max_operations < 0 || max_operations > 10000000 {
    raise InvalidLimit("propagation operations must be 0..10000000")
  }
  if max_trace < 0 || max_trace > 1000000 {
    raise InvalidLimit("trace capacity must be 0..1000000")
  }
  { operations: max_operations, trace: max_trace, }
}

///|
fn with_cells(net : Network, cells : Array[RelSet]) -> Network {
  { names: net.names.copy(), cells, sources: net.sources.copy(), }
}

///|
/// Monotonic path-consistency closure; success is not a SAT claim.
pub fn propagate(
  alg : Algebra,
  net : Network,
  options : PropagationOptions,
) -> ClosureReport {
  let n = net.size()
  let cells = net.cells.copy()
  let trace : Array[Reduction] = []
  let mut operations = 0
  let mut count = 0
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      if cells[i * n + j].is_empty() {
        return {
          status: Contradiction,
          network: with_cells(net, cells),
          operations,
          reductions: trace,
          reduction_count: count,
          trace_complete: true,
          conflict: Some({ left: net.names[i], right: net.names[j], via: None, }),
        }
      }
    }
  }
  let mut changed = true
  while changed {
    changed = false
    for k = 0; k < n; k = k + 1 {
      for i = 0; i < n; i = i + 1 {
        for j = i + 1; j < n; j = j + 1 {
          if operations >= options.operations {
            return {
              status: PropagationLimit,
              network: with_cells(net, cells),
              operations,
              reductions: trace,
              reduction_count: count,
              trace_complete: count == trace.length(),
              conflict: None,
            }
          }
          operations = operations + 1
          let before = cells[i * n + j]
          let after = before.intersect(
            alg.compose(cells[i * n + k], cells[k * n + j]),
          )
          if after != before {
            cells[i * n + j] = after
            cells[j * n + i] = after.converse()
            count = count + 1
            if trace.length() < options.trace {
              trace.push({ left: i, right: j, via: k, before, after, })
            }
            changed = true
            if after.is_empty() {
              return {
                status: Contradiction,
                network: with_cells(net, cells),
                operations,
                reductions: trace,
                reduction_count: count,
                trace_complete: count == trace.length(),
                conflict: Some({
                  left: net.names[i],
                  right: net.names[j],
                  via: Some(net.names[k]),
                }),
              }
            }
          }
        }
      }
    }
  }
  {
    status: PathConsistent,
    network: with_cells(net, cells),
    operations,
    reductions: trace,
    reduction_count: count,
    trace_complete: count == trace.length(),
    conflict: None,
  }
}
