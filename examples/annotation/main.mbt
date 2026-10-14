///|
fn run() -> Unit raise Error {
  // Annotators know ordering alternatives, but no clock timestamps.
  let text =
    #|interval speech
    #|interval gesture
    #|interval response
    #|rel speech gesture o|m annotator-1
    #|rel gesture response m|o annotator-2
  let net = @allen.parse_dsl(text)
  let alg = @allen.Algebra::new()
  let options = @allen.SearchOptions::new()
  let query = @allen.possible_relations(alg, net, "speech", "response", options)
  assert_true(query.unknown.is_empty())
  assert_eq(query.possible, @allen.parse_relset("b|m|o"))
  assert_eq(query.possible.union(query.impossible), @allen.RelSet::all())
  for model in query.models {
    assert_true(model.witness.satisfies(net))
    assert_eq(
      model.witness.get("speech").relate(model.witness.get("response")),
      model.relation,
    )
  }
  println("speech -> response possible: " + query.possible.render())
  // A universal Before claim has a real counterexample, not just a wider domain.
  match
    @allen.entails(
      alg,
      net,
      "speech",
      "response",
      @allen.RelSet::single(Before),
      options,
    ) {
    Refuted(counterexample) => {
      assert_true(counterexample.satisfies(net))
      println(counterexample.render())
    }
    _ => fail("Before-only should have a counterexample")
  }
  assert_true(
    @allen.entails(alg, net, "speech", "response", query.possible, options)
    is Proven,
  )
  let bounded = @allen.possible_relations(
    alg,
    net,
    "speech",
    "response",
    @allen.SearchOptions::new(max_nodes=0),
  )
  assert_true(!bounded.unknown.is_empty())
  assert_true(bounded.possible.is_empty())
  println("annotation: PASS")
}

///|
fn main {
  run() catch {
    e => {
      println("annotation: \{e}")
      abort("annotation failure")
    }
  }
}
