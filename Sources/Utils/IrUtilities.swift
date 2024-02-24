let irBuiltInFuncs = [
  "=", "or", "and", "==", "!=", "<", "<=", ">", ">=", "+", "-", "*", "/", "%", "unary_not",
  "unary_-", "print_int", "print_bool", "read_int"
]
.reduce(into: [String: IrVar]()) { map, op in
  map[op] = IrVar(name: op)
}
