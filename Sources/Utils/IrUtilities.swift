let irBuiltInFuncs = [
  "=", "or", "and", "==", "!=", "<", "<=", ">", ">=", "+", "-", "*", "/", "%", "unary_not",
  "unary_-", "print_int", "print_bool", "read_int"
]
.reduce(into: [String: IrVar]()) { map, op in
  map[op] = IrVar(name: op)
}

/// Returns the IR variables used in the given instructions. Removes duplicates.
func getIrVarsFromInstructions(_ instructions: [(any Instruction)]) -> [IrVar] {
  let irVariables = Set(instructions.flatMap { $0.irVariables })
  return Array(irVariables)
}
