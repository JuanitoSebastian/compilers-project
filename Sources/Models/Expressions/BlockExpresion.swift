struct BlockExpression: Expression, Equatable, CustomStringConvertible {
  var type: ExpressionType = .block
  let statements: [(any Expression)]
  let resultExpression: (any Expression)?

  static func == (lhs: BlockExpression, rhs: BlockExpression) -> Bool {
    if lhs.statements.count == rhs.statements.count
      && areExpressionsEqual(lhs.resultExpression, rhs.resultExpression)
    {
      for (lhs, rhs) in zip(lhs.statements, rhs.statements) where !areExpressionsEqual(lhs, rhs) {
        return false
      }
      return true
    }
    return false
  }

  var description: String {
    return
      "Block(statements: \(statements.map { $0.description }.joined(separator: ", "))) "
      + "result: (\(resultExpression?.description ?? "nil")"
  }
}
