///|
pub(all) struct Constraint {
  left : String
  right : String
  allowed : RelSet
  label : String
} derive(Eq, Debug)

///|
pub extend Constraint with Eq::{equal, not_equal}

///|
pub extend Constraint with @debug.Debug::{to_repr}

///|
/// Immutable named matrix. Accessors copy arrays, and constraints intersect.
pub struct Network {
  priv names : Array[String]
  priv cells : Array[RelSet]
  priv sources : Array[Constraint]
}

///|
fn valid_name(name : String) -> Bool {
  if name.length() == 0 || name.length() > 128 {
    return false
  }
  for c in name.iter() {
    if !(c >= 'a' && c <= 'z') &&
      !(c >= 'A' && c <= 'Z') &&
      !(c >= '0' && c <= '9') &&
      c != '_' &&
      c != '-' &&
      c != '.' {
      return false
    }
  }
  true
}

///|
pub fn Network::new(names : Array[String]) -> Network raise AllenError {
  let n = names.length()
  if n > 64 {
    raise TooLarge(n)
  }
  for i = 0; i < n; i = i + 1 {
    if !valid_name(names[i]) {
      raise InvalidName(names[i])
    }
    for j = 0; j < i; j = j + 1 {
      if names[i] == names[j] {
        raise DuplicateName(names[i])
      }
    }
  }
  let cells = Array::make(n * n, RelSet::all())
  for i = 0; i < n; i = i + 1 {
    cells[i * n + i] = RelSet::single(Equal)
  }
  { names: names.copy(), cells, sources: [], }
}

///|
pub fn Network::size(self : Network) -> Int32 {
  self.names.length()
}

///|
pub fn Network::names(self : Network) -> Array[String] {
  self.names.copy()
}

///|
pub fn Network::constraints(self : Network) -> Array[Constraint] {
  self.sources.copy()
}

///|
pub fn Network::index(self : Network, name : String) -> Int32 raise AllenError {
  for i = 0; i < self.size(); i = i + 1 {
    if self.names[i] == name {
      return i
    }
  }
  raise UnknownName(name)
}

///|
pub fn Network::at(
  self : Network,
  i : Int32,
  j : Int32,
) -> RelSet raise AllenError {
  if i < 0 || i >= self.size() {
    raise InvalidIndex(i)
  }
  if j < 0 || j >= self.size() {
    raise InvalidIndex(j)
  }
  self.cells[i * self.size() + j]
}

///|
pub fn Network::get(
  self : Network,
  left : String,
  right : String,
) -> RelSet raise AllenError {
  self.at(self.index(left), self.index(right))
}

///|
pub fn Network::constrain(
  self : Network,
  constraint : Constraint,
) -> Network raise AllenError {
  if constraint.label.length() > 256 {
    raise InvalidFormat("label too long")
  }
  if self.sources.length() >= 4096 {
    raise TooLarge(self.sources.length() + 1)
  }
  let i = self.index(constraint.left)
  let j = self.index(constraint.right)
  let cells = self.cells.copy()
  let n = self.size()
  let narrowed = cells[i * n + j].intersect(constraint.allowed)
  if i == j {
    cells[i * n + j] = narrowed.intersect(RelSet::single(Equal))
  } else {
    cells[i * n + j] = narrowed
    cells[j * n + i] = narrowed.converse()
  }
  let sources = self.sources.copy()
  sources.push(constraint)
  { names: self.names.copy(), cells, sources, }
}

///|
pub fn Network::restrict(
  self : Network,
  left : String,
  right : String,
  allowed : RelSet,
  label~ : String = "",
) -> Network raise AllenError {
  self.constrain({ left, right, allowed, label, })
}

///|
pub fn Network::from_constraints(
  names : Array[String],
  constraints : Array[Constraint],
) -> Network raise AllenError {
  let mut net = Network::new(names)
  for constraint in constraints {
    net = net.constrain(constraint)
  }
  net
}

///|
pub fn Network::is_atomic(self : Network) -> Bool {
  for set in self.cells {
    if set.size() != 1 {
      return false
    }
  }
  true
}

///|
pub fn Network::same_domains(self : Network, other : Network) -> Bool {
  self.names == other.names && self.cells == other.cells
}

///|
pub fn Network::is_refinement_of(self : Network, other : Network) -> Bool {
  if self.names != other.names {
    return false
  }
  for i = 0; i < self.cells.length(); i = i + 1 {
    if !self.cells[i].subset_of(other.cells[i]) {
      return false
    }
  }
  true
}
