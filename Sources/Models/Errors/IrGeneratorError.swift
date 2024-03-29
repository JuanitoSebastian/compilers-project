enum IrGeneratorError: Error {
  case missingLocation(expression: any Expression)
  case missingType(expression: any Expression)
  case duplicateVarDeclaration(varDeclarationExpression: VarDeclarationExpression)
  case referenceToUndefinedVar(identifier: IdentifierExpression)
  case referenceToUndefinedFunction(function: String)
  case unsupportedExpression(expression: any Expression)
}
