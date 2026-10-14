///|
test "relation set Boolean operations" {
  let x = parse_relset("b|m|o")
  let y = parse_relset("m|eq")
  assert_eq(x.intersect(y), RelSet::single(Meets))
  assert_eq(x.union(y).size(), 4)
  assert_eq(x.difference(y).render(), "b|o")
  assert_true(x.subset_of(RelSet::all()))
  assert_eq(x.converse().render(), "bi|mi|oi")
}

///|
test "all masks preserve size converse and rendering" {
  for mask = 0; mask < 8192; mask = mask + 1 {
    let set = RelSet::from_mask(mask)
    assert_eq(set.converse().converse(), set)
    assert_eq(parse_relset(set.render()), set)
    assert_eq(set.size(), set.items().length())
  }
}

///|
test "malformed mask and empty alternatives rejected" {
  try RelSet::from_mask(8192) catch {
    InvalidMask(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("bad mask")
  }
  try parse_relset("b||m") catch {
    InvalidRelation(_) => ()
    _ => fail("wrong error")
  } noraise {
    _ => fail("empty token")
  }
}
