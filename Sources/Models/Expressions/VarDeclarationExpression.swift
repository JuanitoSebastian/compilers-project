struct VarDeclarationExpression: Expression, Equatable, CustomStringConvertible {
  let type: ExpressionType = .variableDeclaration
  let declaration: BinaryOpExpression

  static func == (lhs: VarDeclarationExpression, rhs: VarDeclarationExpression) -> Bool {
    return lhs.declaration == rhs.declaration
  }

  var description: String {
    return "VarDeclaration(\(declaration))"
  }
}
