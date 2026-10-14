///|
test "relation tokens and converse are bijective" {
  let all = relations()
  assert_eq(all.length(), 13)
  for i = 0; i < 13; i = i + 1 {
    assert_eq(all[i].index(), i)
    assert_eq(parse_relation(all[i].token()), all[i])
    assert_eq(all[i].converse().converse(), all[i])
  }
}

///|
test "invalid relation does not silently become universal" {
  try parse_relation("before") catch {
    InvalidRelation("before") => ()
    _ => fail("wrong error")
  } noraise { _ => fail("expected invalid relation") }
}
