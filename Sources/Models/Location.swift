struct Location: CustomStringConvertible, Equatable {
  let file: String?
  let position: Range<String.Index>?

  var description: String {
    return "Location(file: \(file ?? "nil"), position: \(String(describing: position)))"
  }

  static func == (lhs: Location, rhs: Location) -> Bool {
    if lhs.file == nil && rhs.file == nil {
      return true
    }
    return lhs.file == rhs.file && lhs.position == rhs.position
  }
}
