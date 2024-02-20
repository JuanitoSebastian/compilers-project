struct Label: Instruction, CustomStringConvertible, Equatable {
  let label: String
  let location: Location

  var description: String {
    return "Label(\(label))"
  }

  static func == (lhs: Label, rhs: Label) -> Bool {
    return lhs.label == rhs.label && lhs.location == rhs.location
  }
}
