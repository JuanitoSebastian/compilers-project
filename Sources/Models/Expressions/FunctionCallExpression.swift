struct FunctionCallExpression: Expression, Equatable, CustomStringConvertible {
  let expressionType: ExpressionType = .functionCall
  var identifier: IdentifierExpression
  var arguments: [any Expression]
  let location: Location?
  var type: Type?

  init(
    identifier: IdentifierExpression, arguments: [any Expression], location: Location? = nil
  ) {
    self.identifier = identifier
    self.arguments = arguments
    self.location = location
  }

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

  var description: String {
    return
      "FunctionCallExpression: \(identifier)(\(arguments.map { $0.description }.joined(separator: ", ")))"
  }
}
