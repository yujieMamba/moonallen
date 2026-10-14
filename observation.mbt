///|
/// Import concrete spans as an atomic qualitative network; coordinates are discarded.
pub fn observe(names : Array[String], spans : Array[Interval]) -> Network raise AllenError {
  let net = Network::new(names)
  if names.length() != spans.length() { raise InvalidFormat("observation length mismatch") }
  let n = net.size()
  let cells = net.cells.copy()
  let sources : Array[Constraint] = []
  for i = 0; i < n; i = i + 1 {
    for j = i+1; j < n; j = j + 1 {
      let r = spans[i].relate(spans[j])
      cells[i*n+j] = RelSet::single(r)
      cells[j*n+i] = RelSet::single(r.converse())
      sources.push({left:names[i],right:names[j],allowed:RelSet::single(r),label:"observation"})
    }
  }
  {names:net.names.copy(),cells,sources}
}

///|
pub(all) struct ObservationConflict {
  left : String
  right : String
  expected : RelSet
  observed : Relation
}

///|
/// Check only supplied observations without asserting anything about missing spans.
pub fn check_observations(net : Network, names : Array[String],
                          spans : Array[Interval]) -> Array[ObservationConflict] raise AllenError {
  let observed = observe(names,spans)
  let indexes = names.map(name => net.index(name))
  let out : Array[ObservationConflict] = []
  for i = 0; i < names.length(); i = i + 1 {
    for j = i; j < names.length(); j = j + 1 {
      let expected = net.cells[indexes[i]*net.size()+indexes[j]]
      let actual = observed.cells[i*names.length()+j].items()[0]
      if !expected.has(actual) {
        out.push({left:names[i],right:names[j],expected,observed:actual})
      }
    }
  }
  out
}

///|
/// Add measured qualitative evidence while preserving all earlier source labels.
pub fn add_observations(net : Network, names : Array[String],
                        spans : Array[Interval]) -> Network raise AllenError {
  let observed = observe(names,spans)
  let mut out = net
  for constraint in observed.sources { out = out.constrain(constraint) }
  out
}
