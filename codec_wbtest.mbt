///|
test "JSON roundtrip preserves source strings safely" {
  let label = "引号\" 反斜杠\\\n换行"
  let net = Network::new(["a","b"]).restrict("a","b",parse_relset("b|m"),label~)
  let rebuilt = parse_network_json(net.sources_json().stringify())
  assert_true(rebuilt.same_domains(net))
  assert_eq(rebuilt.constraints()[0].label,label)
  assert_true(parse_network_json(net.to_json().stringify()).same_domains(net))
}

///|
test "JSON rejects schema drift wrong types and malformed text" {
  for text in ["null","[]","{", "{\"format\":\"other\",\"names\":[],\"constraints\":[]}",
               "{\"format\":\"moonallen/1\",\"names\":[3],\"constraints\":[]}",
               "{\"format\":\"moonallen/1\",\"names\":[],\"constraints\":[],\"extra\":0}",
               "{\"format\":\"moonallen/1\",\"names\":[]}"] {
    try { let _ = parse_network_json(text) } catch { _ => () } noraise { _ => fail("accepted invalid JSON") }
  }
}

///|
test "snapshot and source JSON have intentionally different semantics" {
  let original = parse_dsl("interval a\ninterval b\ninterval c\nrel a b b\nrel b c b")
  let closed = propagate(Algebra::new(),original,PropagationOptions::new()).network
  assert_true(parse_network_json(closed.to_json().stringify()).same_domains(closed))
  assert_true(parse_network_json(closed.sources_json().stringify()).same_domains(original))
  let bad = closed.restrict("a","a",RelSet::empty())
  assert_true(parse_network_json(bad.to_json().stringify()).same_domains(bad))
}
