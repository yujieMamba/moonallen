///|
/// Merge current domains by interval name; conflicts remain visible as empty sets.
/// This is a matrix snapshot merge, so source evidence is labeled by input side.
pub fn merge_networks(left : Network, right : Network) -> Network raise AllenError {
  let names = left.names.copy()
  for name in right.names {
    if !names.contains(name) { names.push(name) }
  }
  let mut out = Network::new(names)
  for source in left.domain_constraints(label="merge-left-domain") {
    out = out.constrain(source)
  }
  for source in right.domain_constraints(label="merge-right-domain") {
    out = out.constrain(source)
  }
  out
}

///|
pub(all) struct DomainChange {
  left : String
  right : String
  before : RelSet
  after : RelSet
  removed : RelSet
  added : RelSet
}

///|
/// Compare same-named matrices even when their positional orders differ.
pub fn compare_domains(before : Network, after : Network) -> Array[DomainChange] raise AllenError {
  if before.size() != after.size() { raise InvalidFormat("comparison name sets differ") }
  let positions = before.names.map(name => after.index(name))
  let changes : Array[DomainChange] = []
  let n = before.size()
  for i = 0; i < n; i = i+1 {
    for j = i; j < n; j = j+1 {
      let a = before.cells[i*n+j]
      let b = after.cells[positions[i]*n+positions[j]]
      if a != b {
        changes.push({left:before.names[i],right:before.names[j],before:a,after:b,
                      removed:a.difference(b),added:b.difference(a)})
      }
    }
  }
  changes
}

///|
pub(all) struct NetworkStats {
  intervals : Int
  pairs : Int
  constrained_pairs : Int
  atomic_pairs : Int
  ambiguous_pairs : Int
  empty_domains : Int
  alternatives : Int
  source_constraints : Int
}

///|
pub fn Network::stats(self : Network) -> NetworkStats {
  let n = self.size()
  let mut constrained = 0
  let mut atoms = 0
  let mut ambiguous = 0
  let mut empty = 0
  let mut alternatives = 0
  for i = 0; i < n; i = i+1 {
    if self.cells[i*n+i].is_empty() { empty = empty+1 }
    for j = i+1; j < n; j = j+1 {
      let set = self.cells[i*n+j]
      if set != RelSet::all() { constrained = constrained+1 }
      let count = set.size()
      alternatives = alternatives+count
      if count == 0 { empty = empty+1 }
      else if count == 1 { atoms = atoms+1 }
      else { ambiguous = ambiguous+1 }
    }
  }
  {intervals:n,pairs:n*(n-1)/2,constrained_pairs:constrained,atomic_pairs:atoms,
   ambiguous_pairs:ambiguous,empty_domains:empty,alternatives,source_constraints:self.sources.length()}
}
