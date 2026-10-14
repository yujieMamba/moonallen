///|
pub(all) suberror AllenError {
  InvalidRelation(String)
  InvalidMask(Int32)
  InvalidInterval(Int32, Int32)
  InvalidName(String)
  DuplicateName(String)
  UnknownName(String)
  InvalidIndex(Int32)
  InvalidLimit(String)
  InvalidFormat(String)
  TooLarge(Int32)
}
