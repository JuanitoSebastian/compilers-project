struct Jump: Instruction, Equatable, CustomStringConvertible {
  let label: Label
  let location: Location

  var description: String {
    return "Jump(\(label))"
  }

  static func == (lhs: Jump, rhs: Jump) -> Bool {
    return lhs.label == rhs.label && lhs.location == rhs.location
  }
}
