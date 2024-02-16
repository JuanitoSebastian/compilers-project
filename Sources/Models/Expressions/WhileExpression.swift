struct WhileExpression: Expression, Equatable, CustomStringConvertible {
  let expressionType: ExpressionType = .whileExpression
  let condition: (any Expression)
  let body: BlockExpression
  let location: Location?
  var type: Type?

  init(
    condition: (any Expression), body: BlockExpression, location: Location? = nil
  ) {
    self.condition = condition
    self.body = body
    self.location = location
  }

  static func == (lhs: WhileExpression, rhs: WhileExpression) -> Bool {
    return areExpressionsEqual(lhs.condition, rhs.condition)
      && areExpressionsEqual(lhs.body, rhs.body)
  }

  var description: String {
    return "While(condition: (\(condition)) body: (\(body)))"
  }
}
