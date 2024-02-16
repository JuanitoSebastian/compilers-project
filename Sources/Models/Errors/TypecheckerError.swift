enum TypecheckerError: Error, Equatable {
  case inaproppriateType(expected: [Type], got: [Type], location: Location?)
  case unsupportedOperator(op: String, location: Location?)
  case referenceToUndefinedIdentifier(identifier: String, location: Location?)
  case identifierAlreadyDeclared(identifier: String, location: Location?)
  case wrongNumberOfArguments(expected: Int, got: Int, location: Location?)
  case unknownExpressionType(type: String, location: Location?)
}
