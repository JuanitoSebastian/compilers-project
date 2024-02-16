struct IfExpression: Expression, Equatable, CustomStringConvertible {
  let expressionType: ExpressionType = .ifExpression

  let condition: (any Expression)
  let thenExpression: (any Expression)
  let elseExpression: (any Expression)?

  let location: Location?

  init(
    condition: (any Expression), thenExpression: (any Expression),
    elseExpression: (any Expression)?, location: Location? = nil
  ) {
    self.condition = condition
    self.thenExpression = thenExpression
    self.elseExpression = elseExpression
    self.location = location
  }

  static func == (lhs: IfExpression, rhs: IfExpression) -> Bool {
    return areExpressionsEqual(lhs.condition, rhs.condition)
      && areExpressionsEqual(lhs.thenExpression, rhs.thenExpression)
      && areExpressionsEqual(lhs.elseExpression, rhs.elseExpression)
  }

  var description: String {
    return
      "IfExpression: (\(condition)) then (\(thenExpression))"
      + "\(elseExpression != nil ? " else (\(elseExpression!))" : "")"
  }
}
