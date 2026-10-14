///|
/// Composition built from all weak order types of six endpoints.
/// Any three intervals compress to at most six distinct ordered coordinates.
pub struct Algebra {
  priv table : Array[RelSet]
}

///|
pub fn Algebra::new() -> Algebra {
  let table = Array::make(169, RelSet::empty())
  let spans : Array[(Int,Int)] = []
  for a = 0; a < 6; a = a + 1 {
    for b = a + 1; b < 6; b = b + 1 { spans.push((a,b)) }
  }
  for (a,b) in spans {
    for (c,d) in spans {
      let ab = classify(a,b,c,d).index()
      for (e,f) in spans {
        let bc = classify(c,d,e,f).index()
        let ac = classify(a,b,e,f)
        let slot = ab * 13 + bc
        table[slot] = table[slot].union(RelSet::single(ac))
      }
    }
  }
  { table, }
}

///|
pub fn Algebra::compose_atoms(self : Algebra, a : Relation, b : Relation) -> RelSet {
  self.table[a.index() * 13 + b.index()]
}

///|
pub fn Algebra::compose(self : Algebra, a : RelSet, b : RelSet) -> RelSet {
  let mut out = RelSet::empty()
  for x in a.items() {
    for y in b.items() { out = out.union(self.compose_atoms(x,y)) }
  }
  out
}

///|
pub fn Algebra::row(self : Algebra, a : Relation) -> Array[RelSet] {
  relations().map(b => self.compose_atoms(a,b))
}
