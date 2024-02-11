struct VarDeclarationExpression: Expression, Equatable, CustomStringConvertible {
  let type: ExpressionType = .variableDeclaration
  let variableIdentifier: IdentifierExpression
  let variableValue: (any Expression)
  let variableType: Type?

  init(
    variableIdentifier: IdentifierExpression, variableValue: (any Expression),
    variableType: Type? = nil
  ) {
    self.variableIdentifier = variableIdentifier
    self.variableValue = variableValue
    self.variableType = variableType
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
