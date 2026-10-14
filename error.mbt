///|
pub(all) suberror AllenError {
  InvalidRelation(String)
  InvalidMask(Int)
  InvalidInterval(Int, Int)
  InvalidName(String)
  DuplicateName(String)
  UnknownName(String)
  InvalidIndex(Int)
  InvalidLimit(String)
  InvalidFormat(String)
  TooLarge(Int)
} derive(Debug, Eq)
