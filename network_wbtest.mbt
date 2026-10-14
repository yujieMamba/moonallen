///|
test "network copies input and accessor arrays" {
  let names = ["a", "b"]
  let net = Network::new(names)
  names[0] = "changed"
  let out = net.names()
  out[0] = "changed-again"
  assert_eq(net.names(), ["a", "b"])
  let restricted = net.restrict("a", "b", parse_relset("b|m"), label="source")
  assert_eq(net.get("a", "b"), RelSet::all())
  assert_eq(restricted.get("b", "a").render(), "bi|mi")
  let sources = restricted.constraints()
  sources.clear()
  assert_eq(restricted.constraints().length(), 1)
}

///|
test "repeated constraints intersect rather than replace" {
  let net = Network::new(["a", "b"]).restrict("a", "b", parse_relset("b|m"))
  assert_eq(
    net.restrict("a", "b", parse_relset("m|o")).get("a", "b").render(),
    "m",
  )
  assert_true(
    net.restrict("a", "b", parse_relset("o")).get("a", "b").is_empty(),
  )
  assert_true(
    net.restrict("a", "a", parse_relset("b")).get("a", "a").is_empty(),
  )
}

///|
test "network rejects duplicates invalid names and indices" {
  try Network::new(["a", "a"]) catch {
    DuplicateName(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("duplicate accepted")
  }
  try Network::new(["a b"]) catch {
    InvalidName(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("bad name")
  }
  try Network::new([]).at(0, 0) catch {
    InvalidIndex(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("bad index")
  }
}
