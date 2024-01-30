struct IfExpression: Expression, Equatable {
  let type: ExpressionType = .ifExpression

  let condition: (any Expression)
  let thenExpression: (any Expression)
  let elseExpression: (any Expression)?

  static func == (lhs: IfExpression, rhs: IfExpression) -> Bool {
    return areExpressionsEqual(lhs.condition, rhs.condition)
      && areExpressionsEqual(lhs.thenExpression, rhs.thenExpression)
      && areExpressionsEqual(lhs.elseExpression, rhs.elseExpression)
  }
}
