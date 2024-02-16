enum TypecheckerError: Error, Equatable {
  case inaproppriateType(expected: [Type], got: [Type], location: Location?)
  case unsupportedOperator(op: String, location: Location?)
  case referenceToUndefinedIdentifier(identifier: String, location: Location?)
  case identifierAlreadyDeclared(identifier: String)
  case wrongNumberOfArguments(expected: Int, got: Int)
  case unknownExpressionType(type: String)
}
