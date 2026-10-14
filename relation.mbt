///|
/// The thirteen jointly exhaustive, pairwise disjoint proper-interval relations.
pub(all) enum Relation {
  Before
  Meets
  Overlaps
  Starts
  During
  Finishes
  Equal
  After
  MetBy
  OverlappedBy
  StartedBy
  Contains
  FinishedBy
} derive(Eq, Debug)

///|
pub fn Relation::index(self : Relation) -> Int {
  match self {
    Before => 0
    Meets => 1
    Overlaps => 2
    Starts => 3
    During => 4
    Finishes => 5
    Equal => 6
    After => 7
    MetBy => 8
    OverlappedBy => 9
    StartedBy => 10
    Contains => 11
    FinishedBy => 12
  }
}

///|
pub fn relations() -> Array[Relation] {
  [
    Before,
    Meets,
    Overlaps,
    Starts,
    During,
    Finishes,
    Equal,
    After,
    MetBy,
    OverlappedBy,
    StartedBy,
    Contains,
    FinishedBy,
  ]
}

///|
pub fn Relation::token(self : Relation) -> String {
  match self {
    Before => "b"
    Meets => "m"
    Overlaps => "o"
    Starts => "s"
    During => "d"
    Finishes => "f"
    Equal => "eq"
    After => "bi"
    MetBy => "mi"
    OverlappedBy => "oi"
    StartedBy => "si"
    Contains => "di"
    FinishedBy => "fi"
  }
}

///|
pub fn Relation::converse(self : Relation) -> Relation {
  match self {
    Before => After
    Meets => MetBy
    Overlaps => OverlappedBy
    Starts => StartedBy
    During => Contains
    Finishes => FinishedBy
    Equal => Equal
    After => Before
    MetBy => Meets
    OverlappedBy => Overlaps
    StartedBy => Starts
    Contains => During
    FinishedBy => Finishes
  }
}

///|
pub fn parse_relation(text : String) -> Relation raise AllenError {
  for r in relations() {
    if r.token() == text {
      return r
    }
  }
  raise InvalidRelation(text)
}

///|
pub extend Relation with Eq::{equal, not_equal}

///|
pub extend Relation with @debug.Debug::{to_repr}
