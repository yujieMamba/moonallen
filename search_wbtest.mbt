///|
test "disjunctive search returns externally checkable model" {
  let net = Network::new(["a","b","c"])
    .restrict("a","b",parse_relset("b|m|o"))
    .restrict("b","c",parse_relset("d|eq"))
  let r = solve(Algebra::new(),net,SearchOptions::new())
  match r.outcome { Satisfiable(w) => assert_true(w.satisfies(net)); _ => fail("expected model") }
  assert_true(r.nodes > 1)
  assert_true(r.maximum_depth > 0)
}

///|
test "search distinguishes global node and operation budgets" {
  let net = Network::new(["a","b"])
  let alg = Algebra::new()
  assert_true(solve(alg,net,SearchOptions::new(max_nodes=1)).outcome is Unknown(NodeBudget))
  assert_true(solve(alg,net,SearchOptions::new(max_operations=0)).outcome is Unknown(OperationBudget))
  assert_true(solve(alg,net,SearchOptions::new()).outcome is Satisfiable(_))
}

///|
test "search proves contradictions and handles empty network" {
  let alg = Algebra::new()
  let net = Network::new(["a","b"]).restrict("a","b",RelSet::empty())
  assert_true(solve(alg,net,SearchOptions::new()).outcome is Unsatisfiable)
  assert_true(solve(alg,Network::new([]),SearchOptions::new()).outcome is Satisfiable(_))
}
