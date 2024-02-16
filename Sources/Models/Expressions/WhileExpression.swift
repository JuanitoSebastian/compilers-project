struct WhileExpression: Expression, Equatable, CustomStringConvertible {
  let expressionType: ExpressionType = .whileExpression
  let condition: (any Expression)
  let body: BlockExpression

  static func == (lhs: WhileExpression, rhs: WhileExpression) -> Bool {
    return areExpressionsEqual(lhs.condition, rhs.condition)
      && areExpressionsEqual(lhs.body, rhs.body)
  }

  var description: String {
    return "While(condition: (\(condition)) body: (\(body)))"
  }
}
