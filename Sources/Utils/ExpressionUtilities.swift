func areExpressionsEqual(_ lhs: (any Expression)?, _ rhs: (any Expression)?) -> Bool {
  guard let lhs = lhs, let rhs = rhs, lhs.expressionType == rhs.expressionType else {
    return lhs == nil && rhs == nil
  }

  switch lhs.expressionType {
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
  case .not:
    return (lhs as? NotExpression) == (rhs as? NotExpression)
  case .block:
    return (lhs as? BlockExpression) == (rhs as? BlockExpression)
  case .variableDeclaration:
    return (lhs as? VarDeclarationExpression) == (rhs as? VarDeclarationExpression)
  case .whileExpression:
    return (lhs as? WhileExpression) == (rhs as? WhileExpression)
  }
}

let leftAssociativeBinaryOperators: [[String]] = [
  ["="],
  ["or"],
  ["and"],
  ["==", "!="],
  ["<", "<=", ">", ">="],
  ["+", "-"],
  ["*", "/", "%"]
]
