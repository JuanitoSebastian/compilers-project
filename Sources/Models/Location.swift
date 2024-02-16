struct Location: CustomStringConvertible, Equatable {
  let file: String?
  let range: Range<String.Index>?
  let line: Int
  let position: Int

  var description: String {
    let fileDescription = file == nil ? "" : "file: \(file!), "
    let rangeDescription = range == nil ? "" : "range: \(range!), "
    return "Location(\(fileDescription)\(rangeDescription)line: \(line), position: \(position))"
  }

  static func == (lhs: Location, rhs: Location) -> Bool {
    if lhs.file == nil && rhs.file == nil {
      return lhs.line == rhs.line && lhs.position == rhs.position
    }
    return lhs.file == rhs.file && lhs.range == rhs.range && lhs.line == rhs.line
      && lhs.position == rhs.position
  }
}
