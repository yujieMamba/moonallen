///|
test "complete reduction trace is replayable and forged steps fail" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b", "c"])
    .restrict("a", "b", parse_relset("m"))
    .restrict("b", "c", parse_relset("m"))
  let r = propagate(alg, net, PropagationOptions::new())
  assert_true(verify_trace(alg, net, r))
  let step = r.reductions[0]
  r.reductions[0] = {
    left: step.left,
    right: step.right,
    via: step.via,
    before: step.before,
    after: RelSet::all(),
  }
  assert_true(!verify_trace(alg, net, r))
}

///|
test "contradiction traces and truncated trace policy" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b"]).restrict("a", "b", RelSet::empty())
  assert_true(
    verify_trace(alg, net, propagate(alg, net, PropagationOptions::new())),
  )
  let transitive = Network::new(["a", "b", "c"])
    .restrict("a", "b", parse_relset("b"))
    .restrict("b", "c", parse_relset("b"))
  let r = propagate(alg, transitive, PropagationOptions::new(max_trace=0))
  assert_true(!verify_trace(alg, transitive, r))
  assert_true(is_path_consistent(alg, r.network))
}
