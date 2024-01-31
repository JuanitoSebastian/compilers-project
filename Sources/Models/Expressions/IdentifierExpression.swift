struct IdentifierExpression: Expression, Equatable, CustomStringConvertible {
  let type: ExpressionType = .identifier
  let value: String

  static func == (lhs: IdentifierExpression, rhs: IdentifierExpression) -> Bool {
    return lhs.type == rhs.type && lhs.value == rhs.value
  }

  var description: String {
    return "\(value)"
  }
}
