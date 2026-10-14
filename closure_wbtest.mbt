///|
test "transitive narrowing and closure idempotence" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b", "c"])
    .restrict("a", "b", parse_relset("m"))
    .restrict("b", "c", parse_relset("m"))
  let r = propagate(alg, net, PropagationOptions::new())
  assert_eq(r.status, PathConsistent)
  assert_eq(r.network.get("a", "c").render(), "b")
  assert_true(r.network.is_refinement_of(net))
  assert_true(r.trace_complete)
  assert_eq(
    propagate(alg, r.network, PropagationOptions::new()).reduction_count,
    0,
  )
}

///|
test "inconsistent triangle and diagonal detected" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b", "c"])
    .restrict("a", "b", parse_relset("b"))
    .restrict("b", "c", parse_relset("b"))
    .restrict("c", "a", parse_relset("b"))
  assert_eq(
    propagate(alg, net, PropagationOptions::new()).status,
    Contradiction,
  )
  let diagonal = Network::new(["a"]).restrict("a", "a", parse_relset("b"))
  assert_eq(
    propagate(alg, diagonal, PropagationOptions::new()).status,
    Contradiction,
  )
}

///|
test "operation and trace limits are honest" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b", "c"])
    .restrict("a", "b", parse_relset("b"))
    .restrict("b", "c", parse_relset("b"))
  let limited = propagate(alg, net, PropagationOptions::new(max_operations=0))
  assert_eq(limited.status, PropagationLimit)
  assert_true(limited.network.same_domains(net))
  let no_trace = propagate(alg, net, PropagationOptions::new(max_trace=0))
  assert_eq(no_trace.status, PathConsistent)
  assert_true(!no_trace.trace_complete)
  assert_true(no_trace.reduction_count > 0)
}
