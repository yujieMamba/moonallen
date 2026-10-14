///|
test "each relation has a concrete witness" {
  let a = Interval::new(2, 5)
  let others = [(6,8),(5,8),(4,8),(2,8),(1,8),(1,5),(2,5),
                (0,1),(0,2),(0,4),(2,4),(3,4),(3,5)]
  for i = 0; i < 13; i = i + 1 {
    let (s,e) = others[i]
    let b = Interval::new(s,e)
    assert_eq(a.relate(b), relations()[i])
    assert_eq(b.relate(a), relations()[i].converse())
  }
}

///|
test "classification is exhaustive and avoids coordinate subtraction" {
  for a = 0; a < 6; a = a + 1 {
    for b = a + 1; b < 6; b = b + 1 {
      for c = 0; c < 6; c = c + 1 {
        for d = c + 1; d < 6; d = d + 1 {
          let x = Interval::new(a,b)
          let y = Interval::new(c,d)
          assert_eq(x.relate(y).converse(), y.relate(x))
        }
      }
    }
  }
  assert_eq(Interval::new(-2147483648,2147483647).relate(Interval::new(0,1)),Contains)
}

///|
test "point and backwards intervals are rejected" {
  try Interval::new(1,1) catch { InvalidInterval(1,1) => (); _ => fail("wrong error") } noraise { _ => fail("point accepted") }
  try Interval::new(2,1) catch { InvalidInterval(2,1) => (); _ => fail("wrong error") } noraise { _ => fail("backwards accepted") }
}
