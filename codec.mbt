///|
fn object_fields(
  value : Json,
  allowed : Array[String],
) -> Map[String, Json] raise AllenError {
  guard value is Object(fields) else {
    raise InvalidFormat("expected JSON object")
  }
  for key, _ in fields {
    if !allowed.contains(key) {
      raise InvalidFormat("unknown JSON field: " + key)
    }
  }
  if fields.length() != allowed.length() {
    raise InvalidFormat("missing JSON field")
  }
  fields
}

///|
fn field(fields : Map[String, Json], name : String) -> Json raise AllenError {
  match fields.get(name) {
    Some(value) => value
    None => raise InvalidFormat("missing JSON field: " + name)
  }
}

///|
fn json_string(value : Json) -> String raise AllenError {
  match value {
    String(text) => text
    _ => raise InvalidFormat("expected JSON string")
  }
}

///|
fn json_array(value : Json) -> Array[Json] raise AllenError {
  match value {
    Array(values) => values
    _ => raise InvalidFormat("expected JSON array")
  }
}

///|
fn constraint_json(c : Constraint) -> Json {
  Json::object({
    "left": Json::string(c.left),
    "right": Json::string(c.right),
    "allowed": Json::string(c.allowed.render()),
    "label": Json::string(c.label),
  })
}

///|
/// Schema-strict value decoder. Every object field is required; unknown fields
/// and non-string relation sets are rejected. Empty relation sets are legal.
pub fn network_from_json(value : Json) -> Network raise AllenError {
  let fields = object_fields(value, ["format", "names", "constraints"])
  if json_string(field(fields, "format")) != "moonallen/1" {
    raise InvalidFormat("unsupported MoonAllen JSON format")
  }
  let names_json = json_array(field(fields, "names"))
  if names_json.length() > 64 {
    raise TooLarge(names_json.length())
  }
  let names = names_json.map(json_string)
  let rows = json_array(field(fields, "constraints"))
  if rows.length() > 4096 {
    raise TooLarge(rows.length())
  }
  let mut net = Network::new(names)
  for row in rows {
    let c = object_fields(row, ["left", "right", "allowed", "label"])
    net = net.constrain({
      left: json_string(field(c, "left")),
      right: json_string(field(c, "right")),
      allowed: parse_relset(json_string(field(c, "allowed"))),
      label: json_string(field(c, "label")),
    })
  }
  net
}

///|
/// Bounded core JSON parser (1 Mi UTF-16 units, depth 16). Duplicate object keys
/// follow core JSON last-key-wins semantics; use unique keys for interchange.
pub fn parse_network_json(text : String) -> Network raise AllenError {
  if text.length() > 1048576 {
    raise TooLarge(text.length())
  }
  let mut depth = 0
  let mut quoted = false
  let mut escaped = false
  for c in text.iter() {
    if quoted {
      if escaped {
        escaped = false
      } else if c == '\\' {
        escaped = true
      } else if c == '"' {
        quoted = false
      }
    } else if c == '"' {
      quoted = true
    } else if c == '{' || c == '[' {
      depth = depth + 1
      if depth > 16 {
        raise InvalidFormat("JSON depth exceeds 16")
      }
    } else if c == '}' || c == ']' {
      depth = depth - 1
    }
  }
  let value = @json.parse(text) catch {
    _ => raise InvalidFormat("malformed or over-deep JSON")
  }
  network_from_json(value)
}

///|
/// Current-domain snapshot. Original labels are not attributed to deductions.
pub fn Network::to_json(self : Network) -> Json {
  Json::object({
    "format": Json::string("moonallen/1"),
    "names": Json::array(self.names.map(name => Json::string(name))),
    "constraints": Json::array(
      self.domain_constraints(label="snapshot").map(constraint_json),
    ),
  })
}

///|
/// Export original evidence separately. For propagated networks, decoding this
/// reconstructs the input domains, not the narrower inferred snapshot.
pub fn Network::sources_json(self : Network) -> Json {
  Json::object({
    "format": Json::string("moonallen/1"),
    "names": Json::array(self.names.map(name => Json::string(name))),
    "constraints": Json::array(self.sources.map(constraint_json)),
  })
}
