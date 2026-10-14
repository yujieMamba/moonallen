///|
test "DSL accepts forward references comments and CRLF" {
  let n = parse_dsl(
    "# input\r\nrel a b b|m source\r\ninterval a\ninterval\tb\n",
  )
  assert_eq(n.get("a", "b"), parse_relset("b|m"))
  assert_true(parse_dsl(n.to_dsl()).same_domains(n))
}

///|
test "DSL malformed statements and duplicate names are rejected" {
  for
    text in [
      "interval", "interval a extra", "rel a b b x y", "interval a\ninterval a",
      "interval a\nrel a missing b", "interval a\nrel a a ???", "wat a",
    ] {
    try {
      let _ = parse_dsl(text)
    } catch {
      _ => ()
    } noraise {
      _ => fail("accepted malformed DSL")
    }
  }
}

///|
test "DSL roundtrips closure contradictions and empty networks" {
  let alg = Algebra::new()
  let n = parse_dsl("interval a\ninterval b\ninterval c\nrel a b b\nrel b c b")
  let closed = propagate(alg, n, PropagationOptions::new()).network
  assert_true(parse_dsl(closed.to_dsl()).same_domains(closed))
  let bad = n.restrict("a", "a", RelSet::empty())
  assert_true(parse_dsl(bad.to_dsl()).same_domains(bad))
  assert_eq(parse_dsl("").size(), 0)
}
