struct IdentifierExpression: Expression, Equatable, CustomStringConvertible {
  let expressionType: ExpressionType = .identifier
  let value: String
  let location: Location?
  var type: Type?

  init(value: String, location: Location? = nil) {
    self.value = value
    self.location = location
  }

  static func == (lhs: IdentifierExpression, rhs: IdentifierExpression) -> Bool {
    return lhs.expressionType == rhs.expressionType && lhs.value == rhs.value
  }

  var description: String {
    return "\(value)"
  }
}
