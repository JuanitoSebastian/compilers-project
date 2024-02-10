struct VarDeclarationExpression: Expression, Equatable, CustomStringConvertible {
  let type: ExpressionType = .variableDeclaration
  let declaration: BinaryOpExpression
  let variableType: Type?

  init(declaration: BinaryOpExpression, variableType: Type? = nil) {
    self.declaration = declaration
    self.variableType = variableType
  }

  static func == (lhs: VarDeclarationExpression, rhs: VarDeclarationExpression) -> Bool {
    return lhs.declaration == rhs.declaration
  }

  var description: String {
    return "VarDeclaration(\(declaration))"
  }
}
