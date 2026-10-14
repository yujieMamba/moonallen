///|
test "deletion core removes irrelevant source and is subset minimal" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b", "c", "d"])
    .restrict("a", "b", parse_relset("b"), label="ab")
    .restrict("b", "c", parse_relset("b"), label="bc")
    .restrict("c", "a", parse_relset("b"), label="ca")
    .restrict("a", "d", parse_relset("b|m"), label="irrelevant")
  match explain_unsat(alg, net, SearchOptions::new()) {
    ConflictCore(core) => {
      assert_true(core.minimal)
      assert_eq(core.constraints.length(), 3)
      assert_true(
        verify_core(alg, net.names(), core, SearchOptions::new()).outcome
        is Unsatisfiable,
      )
      for removed = 0
          removed < core.constraints.length()
          removed = removed + 1 {
        let remaining : Array[Constraint] = []
        for i = 0; i < core.constraints.length(); i = i + 1 {
          if i != removed {
            remaining.push(core.constraints[i])
          }
        }
        assert_true(
          solve(
            alg,
            Network::from_constraints(net.names(), remaining),
            SearchOptions::new(),
          ).outcome
          is Satisfiable(_),
        )
      }
    }
    _ => fail("missing conflict core")
  }
}

///|
test "core limits never claim minimality or UNSAT without proof" {
  let alg = Algebra::new()
  let net = Network::new(["a", "b"]).restrict("a", "b", RelSet::empty())
  match explain_unsat(alg, net, SearchOptions::new(), max_checks=1) {
    ConflictCore(c) => {
      assert_true(!c.minimal)
      assert_eq(c.checks, 1)
    }
    _ => fail("missing bounded core")
  }
  assert_true(
    explain_unsat(alg, net, SearchOptions::new(max_nodes=0)) is CoreUnknown(_),
  )
  assert_true(
    explain_unsat(alg, Network::new([]), SearchOptions::new())
    is SourceSatisfiable(_),
  )
}
