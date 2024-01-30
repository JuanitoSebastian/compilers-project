struct FunctionCallExpression: Expression, Equatable {
  let type: ExpressionType = .functionCall
  let identifier: IdentifierExpression
  let arguments: [any Expression]

  static func == (lhs: FunctionCallExpression, rhs: FunctionCallExpression) -> Bool {
    if areExpressionsEqual(lhs.identifier, rhs.identifier)
      && lhs.arguments.count == rhs.arguments.count
    {
      let argumentsEqual = zip(lhs.arguments, rhs.arguments).allSatisfy { lhs, rhs in
        areExpressionsEqual(lhs, rhs)
      }
      return argumentsEqual
    }
    return false
  }
}
