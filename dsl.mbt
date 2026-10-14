///|
fn words(line : String) -> Array[String] {
  let out : Array[String] = []
  for part in line.split(" ") {
    for word in part.split("\t") {
      let text = word.trim().to_owned()
      if text != "" {
        out.push(text)
      }
    }
  }
  out
}

///|
/// Bounded line DSL: interval NAME; rel LEFT RIGHT SET [ASCII-LABEL].
/// Only whole-line # comments are recognized. Declarations may follow relations.
pub fn parse_dsl(text : String) -> Network raise AllenError {
  if text.length() > 1048576 {
    raise TooLarge(text.length())
  }
  let names : Array[String] = []
  let constraints : Array[Constraint] = []
  let mut line_number = 0
  for raw in text.split("\n") {
    line_number = line_number + 1
    if line_number > 10000 {
      raise TooLarge(line_number)
    }
    let line = raw.trim().to_owned()
    if line == "" || line.has_prefix("#") {
      continue
    }
    let fields = words(line)
    if fields.length() == 2 && fields[0] == "interval" {
      if names.length() >= 64 {
        raise TooLarge(names.length() + 1)
      }
      names.push(fields[1])
    } else if (fields.length() == 4 || fields.length() == 5) &&
      fields[0] == "rel" {
      if constraints.length() >= 4096 {
        raise TooLarge(constraints.length() + 1)
      }
      let label = if fields.length() == 5 {
        fields[4]
      } else {
        "line-\{line_number}"
      }
      if !valid_name(label) {
        raise InvalidFormat("DSL label must be an ASCII name")
      }
      constraints.push({
        left: fields[1],
        right: fields[2],
        allowed: parse_relset(fields[3]),
        label,
      })
    } else {
      raise InvalidFormat("invalid DSL statement on line \{line_number}")
    }
  }
  Network::from_constraints(names, constraints)
}

///|
/// Export the current matrix, not original provenance. Inferred domains get
/// explicit snapshot labels. The result parses to exactly the same domains.
pub fn Network::to_dsl(self : Network) -> String {
  let lines : Array[String] = [
    "# MoonAllen matrix snapshot; not original evidence",
  ]
  for name in self.names {
    lines.push("interval \{name}")
  }
  for c in self.domain_constraints(label="snapshot") {
    lines.push("rel \{c.left} \{c.right} \{c.allowed.render()} snapshot")
  }
  lines.join("\n") + "\n"
}
