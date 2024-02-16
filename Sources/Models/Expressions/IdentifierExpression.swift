struct IdentifierExpression: Expression, Equatable, CustomStringConvertible {
  let expressionType: ExpressionType = .identifier
  let value: String

  static func == (lhs: IdentifierExpression, rhs: IdentifierExpression) -> Bool {
    return lhs.expressionType == rhs.expressionType && lhs.value == rhs.value
  }

  var description: String {
    return "\(value)"
  }
}
