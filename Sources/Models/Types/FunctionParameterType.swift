enum FunctionParameterType: Equatable {
  case equalType
  case definiteType(_ type: Type?)

  static func == (lhs: FunctionParameterType, rhs: FunctionParameterType) -> Bool {
    switch (lhs, rhs) {
    case (.equalType, .equalType):
      return true
    case let (.definiteType(lhsType), .definiteType(rhsType)):
      return lhsType == rhsType
    default:
      return false
    }
  }
}
