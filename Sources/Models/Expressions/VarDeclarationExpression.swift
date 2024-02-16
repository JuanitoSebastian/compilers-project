struct VarDeclarationExpression: Expression, Equatable, CustomStringConvertible {
  let expressionType: ExpressionType = .variableDeclaration
  let variableIdentifier: IdentifierExpression
  let variableValue: (any Expression)
  let variableType: Type?
  let location: Location?
  var type: Type?

  init(
    variableIdentifier: IdentifierExpression, variableValue: (any Expression),
    variableType: Type? = nil, location: Location? = nil
  ) {
    self.variableIdentifier = variableIdentifier
    self.variableValue = variableValue
    self.variableType = variableType
    self.location = location
  }

  static func == (lhs: VarDeclarationExpression, rhs: VarDeclarationExpression) -> Bool {
    return lhs.variableIdentifier == rhs.variableIdentifier
      && areExpressionsEqual(lhs.variableValue, rhs.variableValue)
      && lhs.variableType == rhs.variableType
  }

  var description: String {
    return "VarDeclaration(identifier: (\(variableIdentifier)) value: (\(variableValue)))"
  }
}
