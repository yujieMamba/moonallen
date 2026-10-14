///|
test "reports distinguish closure from SAT and preserve machine readable budgets" {
  let net = parse_dsl("interval a\ninterval b\nrel a b b")
  let alg = Algebra::new()
  let closed = propagate(alg, net, PropagationOptions::new())
  assert_true(@json.valid(closed.to_json().stringify()))
  assert_true(closed.to_json().stringify().contains("path-consistent"))
  let stopped = solve(alg, net, SearchOptions::new(max_nodes=0))
  assert_true(stopped.to_json().stringify().contains("node-budget"))
  let sat = solve(alg, net, SearchOptions::new())
  assert_true(sat.to_json().stringify().contains("ordinal-not-duration"))
  assert_eq(net.render(), "intervals: a, b\na -> b: b")
  assert_eq(
    net.to_dot(),
    "digraph MoonAllen {\n  rankdir=LR;\n  \"a\";\n  \"b\";\n  \"a\" -> \"b\" [label=\"b\", color=\"black\"];\n}\n",
  )
}

///|
test "reporting never interpolates source labels into DOT" {
  let net = Network::new(["a"]).restrict(
    "a",
    "a",
    RelSet::empty(),
    label="\"; evil -> node;",
  )
  assert_true(!net.to_dot().contains("evil"))
  assert_true(net.to_dot().contains("red"))
  assert_true(@json.valid(net.stats().to_json().stringify()))
}
