enum Type {
  case int
  case bool
  case unit
  case function

  var name: String {
    switch self {
    case .int:
      return "Int"
    case .bool:
      return "Bool"
    case .unit:
      return "Unit"
    case .function:
      return "Function"
    }
  }
}
