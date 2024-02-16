struct Location: CustomStringConvertible, Equatable {
  let file: String?
  let range: Range<String.Index>?
  let line: Int?
  let position: Int?

  var description: String {
    let fileDescription = file == nil ? "" : "file: \(file!), "
    let rangeDescription = range == nil ? "" : "range: \(range!), "
    let lineDescription = line == nil ? "" : "line: \(line!), "
    let positionDescription = position == nil ? "" : "position: \(position!)"
    return "Location(\(fileDescription)\(rangeDescription)\(lineDescription)\(positionDescription))"
  }

  static func == (lhs: Location, rhs: Location) -> Bool {
    if lhs.file == nil && rhs.file == nil {
      return lhs.line == rhs.line && lhs.position == rhs.position
    }
    return lhs.file == rhs.file && lhs.range == rhs.range && lhs.line == rhs.line
      && lhs.position == rhs.position
  }
}
