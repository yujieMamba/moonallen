///|
/// Materialize current pairwise domains as fresh evidence.
/// Original source labels are intentionally not claimed for inferred domains.
pub fn Network::domain_constraints(
  self : Network,
  label~ : String = "domain",
) -> Array[Constraint] {
  let out : Array[Constraint] = []
  let n = self.size()
  for i = 0; i < n; i = i + 1 {
    for j = i; j < n; j = j + 1 {
      let set = self.cells[i * n + j]
      let default = if i == j { RelSet::single(Equal) } else { RelSet::all() }
      if set != default {
        out.push({
          left: self.names[i],
          right: self.names[j],
          allowed: set,
          label,
        })
      }
    }
  }
  out
}

///|
/// Induced pairwise view, NOT full existential quantifier elimination.
pub fn Network::induced(
  self : Network,
  names : Array[String],
) -> Network raise AllenError {
  let mut out = Network::new(names)
  let positions = names.map(name => self.index(name))
  for i = 0; i < names.length(); i = i + 1 {
    for j = i; j < names.length(); j = j + 1 {
      let allowed = self.cells[positions[i] * self.size() + positions[j]]
      let default = if i == j { RelSet::single(Equal) } else { RelSet::all() }
      if allowed != default {
        out = out.restrict(names[i], names[j], allowed, label="induced-domain")
      }
    }
  }
  out
}

///|
/// Positional renaming preserves all matrix domains and source labels.
pub fn Network::rename(
  self : Network,
  names : Array[String],
) -> Network raise AllenError {
  let validated = Network::new(names)
  if validated.size() != self.size() {
    raise InvalidFormat("rename length mismatch")
  }
  let sources : Array[Constraint] = []
  for source in self.sources {
    sources.push({
      left: names[self.index(source.left)],
      right: names[self.index(source.right)],
      allowed: source.allowed,
      label: source.label,
    })
  }
  { names: validated.names, cells: self.cells.copy(), sources, }
}

///|
/// Independent components of the non-universal domain graph, including isolates.
pub fn Network::components(self : Network) -> Array[Array[String]] {
  let n = self.size()
  let seen = Array::make(n, false)
  let out : Array[Array[String]] = []
  for seed = 0; seed < n; seed = seed + 1 {
    if seen[seed] {
      continue
    }
    let pending = [seed]
    let members : Array[String] = []
    seen[seed] = true
    let mut cursor = 0
    while cursor < pending.length() {
      let i = pending[cursor]
      cursor = cursor + 1
      members.push(self.names[i])
      for j = 0; j < n; j = j + 1 {
        if !seen[j] && self.cells[i * n + j] != RelSet::all() {
          seen[j] = true
          pending.push(j)
        }
      }
    }
    out.push(members)
  }
  out
}
