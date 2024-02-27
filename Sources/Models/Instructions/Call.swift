struct Call: Instruction, Equatable, CustomStringConvertible {
  let function: IrVar
  let arguments: [IrVar]
  let destination: IrVar
  let location: Location

  static func == (lhs: Call, rhs: Call) -> Bool {
    return lhs.function == rhs.function && lhs.arguments == rhs.arguments
      && lhs.destination == rhs.destination && lhs.location == rhs.location
  }

  var irVariables: [IrVar] {
    return [function, destination] + arguments
  }

  var description: String {
    return "Call(\(function), \(arguments), \(destination))"
  }
}
