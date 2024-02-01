func areExpressionsEqual(_ lhs: (any Expression)?, _ rhs: (any Expression)?) -> Bool {
  guard let lhs = lhs, let rhs = rhs, lhs.type == rhs.type else {
    return lhs == nil && rhs == nil
  }

  switch lhs.type {
  case .literal:
    if let left = lhs as? LiteralExpression<Int>, let right = rhs as? LiteralExpression<Int> {
      return left == right
    } else if let left = lhs as? LiteralExpression<Bool>,
      let right = rhs as? LiteralExpression<Bool>
    {
      return left == right
    } else {
      return false
    }
  case .identifier:
    return (lhs as? IdentifierExpression) == (rhs as? IdentifierExpression)
  case .binaryOp:
    return (lhs as? BinaryOpExpression) == (rhs as? BinaryOpExpression)
  case .ifExpression:
    return (lhs as? IfExpression) == (rhs as? IfExpression)
  case .functionCall:
    return (lhs as? FunctionCallExpression) == (rhs as? FunctionCallExpression)
  }
}

let leftAssociativeBinaryOperators: [[String]] = [
  ["or"],
  ["and"],
  ["==", "!="],
  ["<", "<=", ">", ">="],
  ["+", "-"],
  ["*", "/"]
]
