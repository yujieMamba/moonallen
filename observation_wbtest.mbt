///|
test "concrete observations form an atomic satisfiable network" {
  let spans = [Interval::new(0, 2), Interval::new(2, 4), Interval::new(1, 3)]
  let net = observe(["a", "b", "c"], spans)
  assert_true(net.is_atomic())
  assert_true(net.accepts(spans))
  assert_true(
    solve(Algebra::new(), net, SearchOptions::new()).outcome is Satisfiable(_),
  )
  assert_eq(net.get("a", "b").render(), "m")
}

///|
test "partial observations report pair conflicts and leave missing intervals open" {
  let net = Network::new(["a", "b", "c"]).restrict("a", "b", parse_relset("b"))
  let names = ["a", "b"]
  let spans = [Interval::new(0, 2), Interval::new(2, 4)]
  let conflicts = check_observations(net, names, spans)
  assert_eq(conflicts.length(), 1)
  assert_eq(conflicts[0].observed, Meets)
  let added = add_observations(net, names, spans)
  assert_true(added.get("a", "b").is_empty())
  assert_eq(added.get("a", "c"), RelSet::all())
}
