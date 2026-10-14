///|
/// Proper intervals require start < end. Coordinates have no calendar semantics.
pub struct Interval {
  priv start : Int32
  priv end : Int32
} derive(Eq, Debug)

///|
pub extend Interval with Eq::{equal, not_equal}

///|
pub extend Interval with @debug.Debug::{to_repr}

///|
pub fn Interval::new(start : Int32, end : Int32) -> Interval raise AllenError {
  if start >= end {
    raise InvalidInterval(start, end)
  }
  { start, end, }
}

///|
pub fn Interval::start(self : Interval) -> Int32 {
  self.start
}

///|
pub fn Interval::end(self : Interval) -> Int32 {
  self.end
}

///|
pub fn Interval::relate(self : Interval, other : Interval) -> Relation {
  classify(self.start, self.end, other.start, other.end)
}

///|
fn classify(a : Int32, b : Int32, c : Int32, d : Int32) -> Relation {
  if b < c {
    return Before
  }
  if b == c {
    return Meets
  }
  if a > d {
    return After
  }
  if a == d {
    return MetBy
  }
  if a == c {
    if b < d {
      Starts
    } else if b == d {
      Equal
    } else {
      StartedBy
    }
  } else if b == d {
    if a < c {
      FinishedBy
    } else {
      Finishes
    }
  } else if a < c {
    if b < d {
      Overlaps
    } else {
      Contains
    }
  } else if b < d {
    During
  } else {
    OverlappedBy
  }
}
