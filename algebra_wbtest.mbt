///|
test "composition identity converse and associativity on all atoms" {
  let alg = Algebra::new()
  for a in relations() {
    assert_eq(alg.compose_atoms(a,Equal), RelSet::single(a))
    assert_eq(alg.compose_atoms(Equal,a), RelSet::single(a))
    for b in relations() {
      assert_true(!alg.compose_atoms(a,b).is_empty())
      assert_eq(alg.compose_atoms(a,b).converse(),alg.compose_atoms(b.converse(),a.converse()))
      for c in relations() {
        assert_eq(alg.compose(alg.compose_atoms(a,b),RelSet::single(c)),
                  alg.compose(RelSet::single(a),alg.compose_atoms(b,c)))
      }
    }
  }
}

///|
test "familiar exact composition vectors" {
  let alg = Algebra::new()
  assert_eq(alg.compose_atoms(Before,Before).render(),"b")
  assert_eq(alg.compose_atoms(Meets,Meets).render(),"b")
  assert_eq(alg.compose_atoms(Overlaps,Overlaps).render(),"b|m|o")
  assert_eq(alg.compose_atoms(During,During).render(),"d")
  assert_eq(alg.compose_atoms(Before,After),RelSet::all())
  assert_eq(alg.compose(RelSet::empty(),RelSet::all()),RelSet::empty())
}
