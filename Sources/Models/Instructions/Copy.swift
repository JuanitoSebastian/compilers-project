struct Copy: Instruction, Equatable, CustomStringConvertible {
  let source: IrVar
  let destination: IrVar
  let location: Location

  static func == (lhs: Copy, rhs: Copy) -> Bool {
    return lhs.source == rhs.source && lhs.destination == rhs.destination
      && lhs.location == rhs.location
  }

  var description: String {
    return "Copy(\(source), \(destination))"
  }
}
