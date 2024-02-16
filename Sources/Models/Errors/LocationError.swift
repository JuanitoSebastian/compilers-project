enum LocationError: Error {
  case combineFromDifferentFiles(lhs: String?, rhs: String?)
}
