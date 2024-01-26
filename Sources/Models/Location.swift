struct Location: CustomStringConvertible, Equatable {
  let file: String?
  let position: Range<String.Index>?
  let line: Int?

  var description: String {
    return "Location(file: \(file ?? "nil"), line: \(line ?? -1))"
  }

  static func == (lhs: Location, rhs: Location) -> Bool {
    if lhs.file == nil && rhs.file == nil {
      return lhs.line == rhs.line
    }
    return lhs.file == rhs.file && lhs.position == rhs.position && lhs.line == rhs.line
  }
}
