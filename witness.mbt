///|
pub struct Witness {
  priv names : Array[String]
  priv spans : Array[Interval]
}

///|
pub fn Witness::names(self : Witness) -> Array[String] {
  self.names.copy()
}

///|
pub fn Witness::intervals(self : Witness) -> Array[Interval] {
  self.spans.copy()
}

///|
pub fn Witness::get(self : Witness, name : String) -> Interval raise AllenError {
  for i = 0; i < self.names.length(); i = i + 1 {
    if self.names[i] == name {
      return self.spans[i]
    }
  }
  raise UnknownName(name)
}

///|
/// Check an externally supplied model against every matrix domain.
pub fn Network::accepts(self : Network, spans : Array[Interval]) -> Bool {
  let n = self.size()
  if spans.length() != n {
    return false
  }
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      if !self.cells[i * n + j].has(spans[i].relate(spans[j])) {
        return false
      }
    }
  }
  true
}

///|
pub fn Witness::satisfies(self : Witness, net : Network) -> Bool {
  self.names == net.names && net.accepts(self.spans)
}

///|
fn representative(parents : Array[Int32], node : Int32) -> Int32 {
  let mut r = node
  while parents[r] != r {
    r = parents[r]
  }
  r
}

///|
fn endpoint_requirements(
  r : Relation,
  a : Int32,
  b : Int32,
  c : Int32,
  d : Int32,
  equalities : Array[(Int32, Int32)],
  orders : Array[(Int32, Int32)],
) -> Unit {
  if r.index() > 6 {
    endpoint_requirements(r.converse(), c, d, a, b, equalities, orders)
    return
  }
  match r {
    Before => orders.push((b, c))
    Meets => equalities.push((b, c))
    Overlaps => {
      orders.push((a, c))
      orders.push((c, b))
      orders.push((b, d))
    }
    Starts => {
      equalities.push((a, c))
      orders.push((b, d))
    }
    During => {
      orders.push((c, a))
      orders.push((b, d))
    }
    Finishes => {
      orders.push((c, a))
      equalities.push((b, d))
    }
    Equal => {
      equalities.push((a, c))
      equalities.push((b, d))
    }
    _ => ()
  }
}

///|
/// Atomic networks reduce exactly to endpoint equalities and strict inequalities.
/// None means a cyclic strict order, not failure to find a heuristic schedule.
pub fn realize_atomic(net : Network) -> Witness? raise AllenError {
  if !net.is_atomic() {
    raise InvalidFormat("realization requires atomic domains")
  }
  let n = net.size()
  let equalities : Array[(Int32, Int32)] = []
  let orders : Array[(Int32, Int32)] = []
  for i = 0; i < n; i = i + 1 {
    orders.push((2 * i, 2 * i + 1))
    for j = i + 1; j < n; j = j + 1 {
      endpoint_requirements(
        net.cells[i * n + j].items()[0],
        2 * i,
        2 * i + 1,
        2 * j,
        2 * j + 1,
        equalities,
        orders,
      )
    }
  }
  let parents = Array::makei(2 * n, i => i)
  for (a, b) in equalities {
    let ra = representative(parents, a)
    let rb = representative(parents, b)
    if ra != rb {
      if ra < rb {
        parents[rb] = ra
      } else {
        parents[ra] = rb
      }
    }
  }
  let roots = parents.map(p => representative(parents, p))
  let edges = Array::make(4 * n * n, false)
  let degree = Array::make(2 * n, 0)
  for (a, b) in orders {
    let ra = roots[a]
    let rb = roots[b]
    if ra == rb {
      return None
    }
    let slot = ra * 2 * n + rb
    if !edges[slot] {
      edges[slot] = true
      degree[rb] = degree[rb] + 1
    }
  }
  let ranks = Array::make(2 * n, -1)
  let mut next = 0
  let mut root_count = 0
  for i = 0; i < 2 * n; i = i + 1 {
    if roots[i] == i {
      root_count = root_count + 1
    }
  }
  while next < root_count {
    let mut chosen = -1
    for i = 0; i < 2 * n; i = i + 1 {
      if roots[i] == i && ranks[i] == -1 && degree[i] == 0 {
        chosen = i
        break
      }
    }
    if chosen == -1 {
      return None
    }
    ranks[chosen] = next
    next = next + 1
    for j = 0; j < 2 * n; j = j + 1 {
      if edges[chosen * 2 * n + j] {
        degree[j] = degree[j] - 1
      }
    }
  }
  let spans = Array::makei(n, i => {
    Interval::new(ranks[roots[2 * i]], ranks[roots[2 * i + 1]])
  })
  if !net.accepts(spans) {
    return None
  }
  Some({ names: net.names.copy(), spans, })
}
