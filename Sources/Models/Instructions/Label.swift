struct Label: Instruction, CustomStringConvertible, Equatable {
  let label: String
  let location: Location

  static func == (lhs: Label, rhs: Label) -> Bool {
    return lhs.label == rhs.label && lhs.location == rhs.location
  }

  var irVariables: [IrVar] {
    return []
  }

  var description: String {
    return "Label(\(label))"
  }
}
