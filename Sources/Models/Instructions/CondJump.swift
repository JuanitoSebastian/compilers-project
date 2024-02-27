struct CondJump: Instruction, Equatable, CustomStringConvertible {
  let condition: IrVar
  let thenLabel: Label
  let elseLabel: Label
  let location: Location

  static func == (lhs: CondJump, rhs: CondJump) -> Bool {
    return lhs.condition == rhs.condition && lhs.thenLabel == rhs.thenLabel
      && lhs.elseLabel == rhs.elseLabel && lhs.location == rhs.location
  }

  var irVariables: [IrVar] {
    return [condition]
  }

  var description: String {
    return "CondJump(\(condition), \(thenLabel), \(elseLabel))"
  }
}
