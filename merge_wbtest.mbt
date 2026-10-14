///|
test "merge aligns shared names and surfaces incompatibility" {
  let left = Network::new(["a","b"]).restrict("a","b",parse_relset("b|m"))
  let right = Network::new(["b","a","c"]).restrict("b","a",parse_relset("mi|oi"))
  let merged = merge_networks(left,right)
  assert_eq(merged.names(),["a","b","c"])
  assert_eq(merged.get("a","b").render(),"m")
  assert_eq(merged.get("a","c"),RelSet::all())
  let conflict = merge_networks(left,right.restrict("a","b",parse_relset("o")))
  assert_true(conflict.get("a","b").is_empty())
  assert_eq(conflict.stats().empty_domains,1)
}

///|
test "domain comparisons ignore position and show exact alternatives" {
  let before = Network::new(["a","b"])
  let after = Network::new(["b","a"]).restrict("a","b",parse_relset("b|m"))
  let diff = compare_domains(before,after)
  assert_eq(diff.length(),1)
  assert_eq(diff[0].removed.size(),11)
  assert_true(diff[0].added.is_empty())
  assert_eq(after.stats().ambiguous_pairs,1)
  assert_eq(after.stats().constrained_pairs,1)
}
