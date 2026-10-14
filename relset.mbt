///|
/// A validated set of alternatives, not simultaneous relations.
pub struct RelSet {
  priv bits : Int32
} derive(Eq, Debug)

///|
pub extend RelSet with Eq::{equal, not_equal}

///|
pub extend RelSet with @debug.Debug::{to_repr}

///|
pub fn RelSet::empty() -> RelSet {
  { bits: 0, }
}

///|
pub fn RelSet::all() -> RelSet {
  { bits: 8191, }
}

///|
pub fn RelSet::single(r : Relation) -> RelSet {
  { bits: 1 << r.index(), }
}

///|
pub fn RelSet::from_mask(mask : Int32) -> RelSet raise AllenError {
  if mask < 0 || mask > 8191 {
    raise InvalidMask(mask)
  }
  { bits: mask, }
}

///|
pub fn RelSet::of(items : Array[Relation]) -> RelSet {
  let mut bits = 0
  for r in items {
    bits = bits | (1 << r.index())
  }
  { bits, }
}

///|
pub fn RelSet::mask(self : RelSet) -> Int32 {
  self.bits
}

///|
pub fn RelSet::has(self : RelSet, r : Relation) -> Bool {
  (self.bits & (1 << r.index())) != 0
}

///|
pub fn RelSet::union(self : RelSet, other : RelSet) -> RelSet {
  { bits: self.bits | other.bits, }
}

///|
pub fn RelSet::intersect(self : RelSet, other : RelSet) -> RelSet {
  { bits: self.bits & other.bits, }
}

///|
pub fn RelSet::difference(self : RelSet, other : RelSet) -> RelSet {
  { bits: self.bits & (8191 ^ other.bits), }
}

///|
pub fn RelSet::subset_of(self : RelSet, other : RelSet) -> Bool {
  (self.bits & other.bits) == self.bits
}

///|
pub fn RelSet::is_empty(self : RelSet) -> Bool {
  self.bits == 0
}

///|
pub fn RelSet::size(self : RelSet) -> Int32 {
  let mut n = 0
  for r in relations() {
    if self.has(r) {
      n = n + 1
    }
  }
  n
}

///|
pub fn RelSet::items(self : RelSet) -> Array[Relation] {
  let out = []
  for r in relations() {
    if self.has(r) {
      out.push(r)
    }
  }
  out
}

///|
pub fn RelSet::converse(self : RelSet) -> RelSet {
  RelSet::of(self.items().map(r => r.converse()))
}

///|
pub fn RelSet::render(self : RelSet) -> String {
  if self.is_empty() {
    return "-"
  }
  if self.bits == 8191 {
    return "*"
  }
  self.items().map(r => r.token()).join("|")
}

///|
pub fn parse_relset(text : String) -> RelSet raise AllenError {
  if text == "-" {
    return RelSet::empty()
  }
  if text == "*" {
    return RelSet::all()
  }
  if text == "" {
    raise InvalidRelation(text)
  }
  let mut set = RelSet::empty()
  for part in text.split("|") {
    set = set.union(RelSet::single(parse_relation(part.to_owned())))
  }
  set
}
