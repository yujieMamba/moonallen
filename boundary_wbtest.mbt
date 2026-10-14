///|
test "resource limits reject negative excessive and oversized inputs" {
  try PropagationOptions::new(max_operations=-1) catch {
    InvalidLimit(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("bad budget accepted")
  }
  try SearchOptions::new(max_nodes=1000001) catch {
    InvalidLimit(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("bad budget accepted")
  }
  try PropagationOptions::new(max_trace=1000001) catch {
    InvalidLimit(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("bad trace accepted")
  }
  let names = Array::makei(65, i => "n\{i}")
  try Network::new(names) catch {
    TooLarge(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("large network accepted")
  }
  try
    solve(
      Algebra::new(),
      Network::new(names[0:25].to_owned()),
      SearchOptions::new(),
    )
  catch {
    TooLarge(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("large search accepted")
  }
  try
    Network::new(["a"]).restrict(
      "a",
      "a",
      RelSet::all(),
      label=String::make(257, 'x'),
    )
  catch {
    InvalidFormat(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("long label accepted")
  }
}

///|
test "hypothetical queries do not consume original source capacity" {
  let mut net = Network::new(["a", "b"])
  for _ in 0..<4096 {
    net = net.restrict("a", "b", RelSet::single(Meets))
  }
  let alg = Algebra::new()
  assert_eq(
    possible_relations(alg, net, "a", "b", SearchOptions::new()).possible,
    RelSet::single(Meets),
  )
  assert_true(
    entails(alg, net, "a", "b", RelSet::single(Meets), SearchOptions::new())
    is Proven,
  )
  assert_eq(net.constraints().length(), 4096)
  try net.restrict("a", "b", RelSet::all()) catch {
    TooLarge(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("source limit not enforced")
  }
}

///|
test "all observation names are checked including a singleton" {
  let net = Network::new(["a"])
  try add_observations(net, ["unknown"], [Interval::new(0, 1)]) catch {
    UnknownName(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("unknown singleton accepted")
  }
  try observe(["a"], []) catch {
    InvalidFormat(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("length mismatch accepted")
  }
  try compare_domains(net, Network::new(["b"])) catch {
    UnknownName(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("different names compared")
  }
}

///|
test "bounded JSON scanner handles escaped quotes and rejects excessive depth" {
  let text = String::make(17, '[') + "0" + String::make(17, ']')
  try parse_network_json(text) catch {
    InvalidFormat(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("deep JSON accepted")
  }
  let huge = String::make(1048577, ' ')
  try parse_network_json(huge) catch {
    TooLarge(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("huge JSON accepted")
  }
  try parse_dsl(huge) catch {
    TooLarge(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("huge DSL accepted")
  }
  let n = Network::new(["a", "b"]).restrict(
    "a",
    "b",
    RelSet::all(),
    label="\\\"[[[[{{{{",
  )
  assert_eq(
    parse_network_json(n.sources_json().stringify()).constraints()[0].label,
    "\\\"[[[[{{{{",
  )
}

///|
test "JSON duplicate key behavior is explicit and tested" {
  let n = parse_network_json(
    "{\"format\":\"ignored\",\"format\":\"moonallen/1\",\"names\":[],\"constraints\":[]}",
  )
  assert_eq(n.size(), 0)
}
