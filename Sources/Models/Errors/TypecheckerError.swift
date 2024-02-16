enum TypecheckerError: Error, Equatable {
  case inaproppriateType(expected: [Type], got: [Type], location: Location?)
  case inaproppriateOperatorForType(op: String, type: [Type])
  case unsupportedOperator(op: String)
  case referenceToUndefinedIdentifier(identifier: String)
  case identifierAlreadyDeclared(identifier: String)
  case wrongNumberOfArguments(expected: Int, got: Int)
  case unknownExpressionType(type: String)
}
