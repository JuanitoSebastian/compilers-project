struct NotExpression: Expression, Equatable, CustomStringConvertible {
  var expressionType: ExpressionType = .not
  var value: (any Expression)
  let location: Location?
  var type: Type?

  init(value: (any Expression), location: Location? = nil) {
    self.value = value
    self.location = location
  }

  static func == (lhs: NotExpression, rhs: NotExpression) -> Bool {
    return areExpressionsEqual(lhs.value, rhs.value)
  }

  var description: String {
    return "Not: (\(value))"
  }
}
