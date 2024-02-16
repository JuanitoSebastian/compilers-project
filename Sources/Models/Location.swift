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

  static func combineLocations(lhs: Location?, rhs: Location?) throws -> Location? {
    guard let lhs = lhs, let rhs = rhs else {
      return nil
    }
    guard lhs.file == rhs.file else {
      throw LocationError.combineFromDifferentFiles
    }
    if let lhsRange = lhs.range, let rhsRange = rhs.range {
      let lowerBound = min(lhsRange.lowerBound, rhsRange.lowerBound)
      let upperBound = max(lhsRange.upperBound, rhsRange.upperBound)
      return Location(
        file: lhs.file, range: lowerBound..<upperBound, line: lhs.line, position: lhs.position
      )
    }
    return Location(
      file: lhs.file, range: nil, line: lhs.line, position: lhs.position
    )
  }
}
