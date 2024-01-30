func areExpressionsEqual(_ lhs: (any Expression)?, _ rhs: (any Expression)?) -> Bool {
  guard let lhs = lhs, let rhs = rhs, lhs.type == rhs.type else {
    return lhs == nil && rhs == nil
  }

  switch lhs.type {
  case .literal:
    return (lhs as? LiteralExpression<Int>) == (rhs as? LiteralExpression<Int>)
  case .identifier:
    return (lhs as? IdentifierExpression) == (rhs as? IdentifierExpression)
  case .binaryOp:
    return (lhs as? BinaryOpExpression) == (rhs as? BinaryOpExpression)
  case .ifExpression:
    return (lhs as? IfExpression) == (rhs as? IfExpression)
  }
}
