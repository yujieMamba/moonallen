///|
test "realize every atomic relation and verify exact classification" {
  for r in relations() {
    let net = Network::new(["a","b"]).restrict("a","b",RelSet::single(r))
    let model = realize_atomic(net)
    match model {
      Some(w) => {
        assert_true(w.satisfies(net))
        assert_eq(w.get("a").relate(w.get("b")),r)
      }
      None => fail("valid relation not realizable")
    }
  }
}

///|
test "atomic endpoint cycle rejected without relying on propagation" {
  let net = Network::new(["a","b","c"])
    .restrict("a","b",parse_relset("b"))
    .restrict("b","c",parse_relset("b"))
    .restrict("c","a",parse_relset("b"))
  assert_true(realize_atomic(net) is None)
}

///|
test "empty singleton and shared endpoints produce valid models" {
  assert_true(realize_atomic(Network::new([])) is Some(_))
  assert_true(realize_atomic(Network::new(["a"])) is Some(_))
  let net = Network::new(["a","b","c"])
    .restrict("a","b",parse_relset("m"))
    .restrict("b","c",parse_relset("m"))
    .restrict("a","c",parse_relset("b"))
  match realize_atomic(net) { Some(w) => assert_true(w.satisfies(net)); None => fail("missing witness") }
}
