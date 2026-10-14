///|
pub fn ClosureStatus::token(self : ClosureStatus) -> String {
  match self { PathConsistent => "path-consistent"; Contradiction => "contradiction"; PropagationLimit => "unknown-operation-budget" }
}

///|
pub fn SearchLimit::token(self : SearchLimit) -> String {
  match self { NodeBudget => "node-budget"; OperationBudget => "operation-budget" }
}

///|
/// Compact deterministic pair listing, including empty diagonal constraints.
pub fn Network::render(self : Network) -> String {
  let lines = ["intervals: "+self.names.join(", ")]
  for c in self.domain_constraints() {
    lines.push("\{c.left} -> \{c.right}: \{c.allowed.render()}")
  }
  lines.join("\n")
}

///|
/// Names are restricted ASCII identifiers and all edge labels are canonical
/// relation tokens. User-provided source labels are never interpolated into DOT.
pub fn Network::to_dot(self : Network) -> String {
  let lines = ["digraph MoonAllen {", "  rankdir=LR;"]
  for name in self.names { lines.push("  \"\{name}\";") }
  for c in self.domain_constraints() {
    let color = if c.allowed.is_empty() { "red" } else { "black" }
    lines.push("  \"\{c.left}\" -> \"\{c.right}\" [label=\"\{c.allowed.render()}\", color=\"\{color}\"];")
  }
  lines.push("}")
  lines.join("\n")+"\n"
}

///|
pub fn Witness::to_json(self : Witness) -> Json {
  let rows : Array[Json] = []
  for i = 0; i < self.names.length(); i = i+1 {
    rows.push(Json::object({"name":Json::string(self.names[i]),
          "start":self.spans[i].start().to_json(),"end":self.spans[i].end().to_json()}))
  }
  Json::object({"coordinate_semantics":Json::string("ordinal-not-duration"),"intervals":Json::array(rows)})
}

///|
pub fn Witness::render(self : Witness) -> String {
  let lines = ["ordinal witness (ranks are not durations):"]
  for i = 0; i < self.names.length(); i = i+1 {
    lines.push("\{self.names[i]}: [\{self.spans[i].start()}, \{self.spans[i].end()}]")
  }
  lines.join("\n")
}

///|
fn reduction_json(step : Reduction, net : Network) -> Json {
  // Reports have public fields; keep serialization total even for forged input.
  fn name_at(index : Int) -> Json {
    if index < 0 || index >= net.size() { Json::null() }
    else { Json::string(net.names[index]) }
  }
  Json::object({"left":name_at(step.left),"right":name_at(step.right),"via":name_at(step.via),
                "before":Json::string(step.before.render()),"after":Json::string(step.after.render())})
}

///|
pub fn ClosureReport::to_json(self : ClosureReport) -> Json {
  let conflict = match self.conflict {
    None => Json::null()
    Some(c) => Json::object({"left":Json::string(c.left),"right":Json::string(c.right),
                           "via":match c.via {None => Json::null(); Some(v) => Json::string(v)}})
  }
  Json::object({"status":Json::string(self.status.token()),"operations":self.operations.to_json(),
        "reduction_count":self.reduction_count.to_json(),"trace_complete":self.trace_complete.to_json(),
        "reductions":Json::array(self.reductions.map(step => reduction_json(step,self.network))),
        "conflict":conflict,"network":self.network.to_json()})
}

///|
pub fn SolveReport::to_json(self : SolveReport) -> Json {
  let (status,reason,model) = match self.outcome {
    Satisfiable(w) => ("satisfiable",Json::null(),w.to_json())
    Unsatisfiable => ("unsatisfiable",Json::null(),Json::null())
    Unknown(limit) => ("unknown",Json::string(limit.token()),Json::null())
  }
  Json::object({"status":Json::string(status),"reason":reason,"witness":model,
              "nodes":self.nodes.to_json(),"operations":self.operations.to_json(),
              "maximum_depth":self.maximum_depth.to_json()})
}

///|
pub fn NetworkStats::to_json(self : NetworkStats) -> Json {
  Json::object({"intervals":self.intervals.to_json(),"pairs":self.pairs.to_json(),
    "constrained_pairs":self.constrained_pairs.to_json(),"atomic_pairs":self.atomic_pairs.to_json(),
    "ambiguous_pairs":self.ambiguous_pairs.to_json(),"empty_domains":self.empty_domains.to_json(),
    "alternatives":self.alternatives.to_json(),"source_constraints":self.source_constraints.to_json()})
}
