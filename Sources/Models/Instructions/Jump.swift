struct Jump: Instruction, Equatable, CustomStringConvertible {
  let label: Label
  let location: Location

  static func == (lhs: Jump, rhs: Jump) -> Bool {
    return lhs.label == rhs.label && lhs.location == rhs.location
  }

  var irVariables: [IrVar] {
    return []
  }

  var description: String {
    return "Jump(\(label))"
  }
}
