///|
test "induced pairwise view preserves inferred constraints" {
  let alg = Algebra::new()
  let base = Network::new(["a", "b", "c"])
    .restrict("a", "b", parse_relset("m"))
    .restrict("b", "c", parse_relset("m"))
  let closed = propagate(alg, base, PropagationOptions::new()).network
  let view = closed.induced(["c", "a"])
  assert_eq(view.get("a", "c").render(), "b")
  assert_eq(view.constraints()[0].label, "induced-domain")
  assert_true(view.induced([]).size() == 0)
}

///|
test "renaming preserves labels and components include isolates" {
  let net = Network::new(["a", "b", "c", "d"])
    .restrict("a", "b", parse_relset("b"), label="workflow")
    .restrict("b", "c", parse_relset("o"))
  assert_eq(net.components(), [["a", "b", "c"], ["d"]])
  let renamed = net.rename(["A", "B", "C", "D"])
  assert_eq(renamed.get("A", "B").render(), "b")
  assert_eq(renamed.constraints()[0].label, "workflow")
}
