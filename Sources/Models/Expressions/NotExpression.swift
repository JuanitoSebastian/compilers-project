struct NotExpression: Expression, Equatable, CustomStringConvertible {
  var expressionType: ExpressionType = .not
  let value: (any Expression)

  static func == (lhs: NotExpression, rhs: NotExpression) -> Bool {
    return areExpressionsEqual(lhs.value, rhs.value)
  }

  var description: String {
    return "Not: (\(value))"
  }
}
