///|
pub(all) struct RelationModel {
  relation : Relation
  witness : Witness
}

///|
pub(all) struct PossibilityReport {
  possible : RelSet
  impossible : RelSet
  unknown : RelSet
  models : Array[RelationModel]
  nodes : Int
  operations : Int
}

///|
/// Each atom gets an independent search budget. Unknown is not possible or impossible.
pub fn possible_relations(
  alg : Algebra,
  net : Network,
  left : String,
  right : String,
  options : SearchOptions,
) -> PossibilityReport raise AllenError {
  let domain = net.get(left, right)
  let mut possible = RelSet::empty()
  let mut impossible = RelSet::all().difference(domain)
  let mut unknown = RelSet::empty()
  let models : Array[RelationModel] = []
  let mut nodes = 0
  let mut operations = 0
  for atom in domain.items() {
    let trial = query_domain(net, left, right, RelSet::single(atom))
    let report = solve(alg, trial, options)
    nodes = nodes + report.nodes
    operations = operations + report.operations
    match report.outcome {
      Satisfiable(witness) => {
        possible = possible.union(RelSet::single(atom))
        models.push({ relation: atom, witness, })
      }
      Unsatisfiable => impossible = impossible.union(RelSet::single(atom))
      Unknown(_) => unknown = unknown.union(RelSet::single(atom))
    }
  }
  { possible, impossible, unknown, models, nodes, operations, }
}

///|
pub(all) enum Entailment {
  Proven
  Refuted(Witness)
  InconsistentInput
  EntailmentUnknown(SearchLimit)
}

///|
/// Avoid vacuous entailment by requiring the premise network to be satisfiable.
pub fn entails(
  alg : Algebra,
  net : Network,
  left : String,
  right : String,
  claim : RelSet,
  options : SearchOptions,
) -> Entailment raise AllenError {
  let _ = net.get(left, right)
  match solve(alg, net, options).outcome {
    Unsatisfiable => return InconsistentInput
    Unknown(limit) => return EntailmentUnknown(limit)
    Satisfiable(_) => ()
  }
  let counter = query_domain(net, left, right, RelSet::all().difference(claim))
  match solve(alg, counter, options).outcome {
    Unsatisfiable => Proven
    Unknown(limit) => EntailmentUnknown(limit)
    Satisfiable(w) => Refuted(w)
  }
}

///|
// A hypothetical query narrows a matrix without appending fictional user evidence.
// This also keeps queries valid when the original evidence is at its size limit.
fn query_domain(
  net : Network,
  left : String,
  right : String,
  allowed : RelSet,
) -> Network raise AllenError {
  let i = net.index(left)
  let j = net.index(right)
  let cells = net.cells.copy()
  let n = net.size()
  let narrowed = cells[i * n + j].intersect(allowed)
  cells[i * n + j] = narrowed
  cells[j * n + i] = narrowed.converse()
  with_cells(net, cells)
}
