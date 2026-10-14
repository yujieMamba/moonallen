///|
fn run() -> Unit raise Error {
  // Measurements are local, synthetic, and not distributed media assets.
  let names = ["video","caption","music"]
  let spans = [@allen.Interval::new(0,20),@allen.Interval::new(3,8),@allen.Interval::new(10,25)]
  let observed = @allen.observe(names,spans)
  let policy = @allen.parse_dsl("interval video\ninterval caption\ninterval music\nrel caption video d caption-contained\nrel music video oi backing-track")
  assert_eq(@allen.check_observations(policy,names,spans).length(),0)
  let combined = @allen.merge_networks(policy,observed)
  let alg = @allen.Algebra::new()
  match @allen.solve(alg,combined,@allen.SearchOptions::new()).outcome {
    Satisfiable(w) => assert_true(w.satisfies(combined))
    _ => fail("measurements should satisfy editorial policy")
  }
  let exchanged = @allen.parse_network_json(combined.to_json().stringify())
  assert_true(exchanged.same_domains(combined))
  println(combined.render())
  println(combined.to_dot())
  // A caption extending outside the clip is a concrete policy violation.
  let changed = [@allen.Interval::new(0,20),@allen.Interval::new(18,23),@allen.Interval::new(10,25)]
  let conflicts = @allen.check_observations(policy,names,changed)
  assert_eq(conflicts.length(),1)
  assert_eq(conflicts[0].observed.token(),"o")
  let bad = @allen.add_observations(policy,names,changed)
  let closed = @allen.propagate(alg,bad,@allen.PropagationOptions::new())
  assert_true(closed.status is Contradiction)
  assert_true(@allen.verify_trace(alg,bad,closed))
  println(closed.to_json().stringify())
  println("media: PASS")
}

///|
fn main { run() catch { e => { println("media: \{e}"); abort("media failure") } } }

