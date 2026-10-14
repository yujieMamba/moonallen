///|
test "exact possibility query prunes transitive impossible atoms" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b", "c"])
    .restrict("a", "b", parse_relset("m"))
    .restrict("b", "c", parse_relset("m"))
  let q = possible_relations(alg, net, "a", "c", SearchOptions::new())
  assert_eq(q.possible.render(), "b")
  assert_eq(q.impossible.size(), 12)
  assert_true(q.unknown.is_empty())
  assert_true(q.models[0].witness.satisfies(net))
  assert_true(
    entails(alg, net, "a", "c", parse_relset("b"), SearchOptions::new())
    is Proven,
  )
}

///|
test "entailment returns counterexamples and refuses vacuous input" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b"])
  assert_true(
    entails(alg, net, "a", "b", parse_relset("b"), SearchOptions::new())
    is Refuted(_),
  )
  let bad = net.restrict("a", "b", RelSet::empty())
  assert_true(
    entails(alg, bad, "a", "b", RelSet::all(), SearchOptions::new())
    is InconsistentInput,
  )
  let q = possible_relations(
    alg,
    net,
    "a",
    "b",
    SearchOptions::new(max_nodes=0),
  )
  assert_eq(q.unknown, RelSet::all())
  assert_true(q.possible.is_empty())
  assert_true(q.impossible.is_empty())
}
