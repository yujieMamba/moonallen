///|
/// Independent endpoint predicates: no library classifier, composition, closure,
/// or realization is used by this finite reference model.
fn reference_relation(a : (Int, Int), b : (Int, Int)) -> Int {
  let (x, y) = a
  let (u, v) = b
  if y < u {
    0
  } else if y == u {
    1
  } else if x < u && u < y && y < v {
    2
  } else if x == u && y < v {
    3
  } else if u < x && y < v {
    4
  } else if u < x && y == v {
    5
  } else if x == u && y == v {
    6
  } else if v < x {
    7
  } else if v == x {
    8
  } else if u < x && x < v && v < y {
    9
  } else if x == u && v < y {
    10
  } else if x < u && v < y {
    11
  } else {
    12
  }
}

///|
fn reference_spans() -> Array[(Int, Int)] {
  let out = []
  for start = 0; start < 6; start = start + 1 {
    for end = start + 1; end < 6; end = end + 1 {
      out.push((start, end))
    }
  }
  out
}

///|
test "independent endpoint oracle checks every atomic three-interval network" {
  let spans = reference_spans()
  let possible = Array::make(2197, false)
  for a in spans {
    for b in spans {
      let ab = reference_relation(a, b)
      assert_eq(
        Interval::new(a.0, a.1).relate(Interval::new(b.0, b.1)).index(),
        ab,
      )
      for c in spans {
        possible[ab * 169 +
        reference_relation(a, c) * 13 +
        reference_relation(b, c)] = true
      }
    }
  }
  let alg = Algebra::new()
  let base = Network::new(["a", "b", "c"])
  for ab in relations() {
    for ac in relations() {
      for bc in relations() {
        let n = base
          .restrict("a", "b", RelSet::single(ab))
          .restrict("a", "c", RelSet::single(ac))
          .restrict("b", "c", RelSet::single(bc))
        let expected = possible[ab.index() * 169 + ac.index() * 13 + bc.index()]
        match solve(alg, n, SearchOptions::new()).outcome {
          Satisfiable(w) => {
            assert_true(expected)
            let v = w.intervals().map(span => (span.start(), span.end()))
            assert_eq(reference_relation(v[0], v[1]), ab.index())
            assert_eq(reference_relation(v[0], v[2]), ac.index())
            assert_eq(reference_relation(v[1], v[2]), bc.index())
          }
          Unsatisfiable => assert_true(!expected)
          Unknown(_) => fail("small atomic oracle case exhausted budget")
        }
      }
    }
  }
}

///|
test "256 disjunctive networks agree with exhaustive endpoint assignments" {
  let spans = reference_spans()
  let triples : Array[(Int, Int, Int)] = []
  for a in spans {
    for b in spans {
      for c in spans {
        triples.push(
          (
            reference_relation(a, b),
            reference_relation(a, c),
            reference_relation(b, c),
          ),
        )
      }
    }
  }
  let alg = Algebra::new()
  let base = Network::new(["a", "b", "c"])
  let mut seed = 43
  for case_index = 0; case_index < 256; case_index = case_index + 1 {
    let domains : Array[RelSet] = []
    for _ in 0..<3 {
      seed = (seed * 73 + 19) % 8192
      // Mix sparse and broad domains, including empty domains.
      let mask = if case_index % 3 == 0 { 1 << (seed % 13) } else { seed }
      domains.push(RelSet::from_mask(mask))
    }
    let mut expected = false
    for (ab, ac, bc) in triples {
      if (domains[0].mask() & (1 << ab)) != 0 &&
        (domains[1].mask() & (1 << ac)) != 0 &&
        (domains[2].mask() & (1 << bc)) != 0 {
        expected = true
        break
      }
    }
    let n = base
      .restrict("a", "b", domains[0])
      .restrict("a", "c", domains[1])
      .restrict("b", "c", domains[2])
    let closed = propagate(alg, n, PropagationOptions::new())
    assert_true(verify_trace(alg, n, closed))
    assert_true(closed.network.is_refinement_of(n))
    match solve(alg, n, SearchOptions::new()).outcome {
      Satisfiable(w) => {
        assert_true(expected)
        assert_true(w.satisfies(n))
      }
      Unsatisfiable => assert_true(!expected)
      Unknown(_) => fail("small disjunctive oracle case exhausted budget")
    }
  }
}
