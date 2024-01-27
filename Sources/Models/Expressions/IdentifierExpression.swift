struct IdentifierExpression: Expression, Equatable {
  let type: ExpressionType = .identifier
  let value: String

  static func == (lhs: IdentifierExpression, rhs: IdentifierExpression) -> Bool {
    return lhs.type == rhs.type && lhs.value == rhs.value
  }
}
