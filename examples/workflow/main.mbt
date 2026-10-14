///|
fn run() -> Unit raise Error {
  // A service launch has relative phases, not dates or resource allocations.
  let input =
    #|interval ingest
    #|interval validate
    #|interval publish
    #|rel ingest validate b|m input-ready
    #|rel validate publish m gate
  let alg = @allen.Algebra::new()
  let net = @allen.parse_dsl(input)
  let closure = @allen.propagate(alg,net,@allen.PropagationOptions::new())
  assert_true(@allen.verify_trace(alg,net,closure))
  assert_eq(closure.network.get("ingest","publish"),@allen.RelSet::single(Before))
  match @allen.solve(alg,net,@allen.SearchOptions::new()).outcome {
    Satisfiable(w) => { assert_true(w.satisfies(net)); println(w.render()) }
    _ => fail("workflow must have a concrete witness")
  }
  // An accidental back edge is rejected and explained in original labels.
  let conflict = net.restrict("publish","ingest",@allen.RelSet::single(Before),label="bad-back-edge")
  match @allen.explain_unsat(alg,conflict,@allen.SearchOptions::new()) {
    ConflictCore(core) => {
      assert_true(core.minimal)
      assert_eq(core.constraints.length(),3)
      for c in core.constraints { println("conflict source: "+c.label) }
      assert_true(@allen.verify_core(alg,net.names(),core,@allen.SearchOptions::new()).outcome is Unsatisfiable)
    }
    _ => fail("back edge must have a verified conflict core")
  }
  println("workflow: PASS")
}

///|
fn main {
  run() catch { e => abort("workflow: \{e}") }
}
