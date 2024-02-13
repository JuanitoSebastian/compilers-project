enum TypecheckerError: Error, Equatable {
  case inaproppriateType(expected: [Type], got: [Type])
  case inaproppriateOperatorForType(op: String, type: [Type])
  case unsupportedOperator(op: String)
  case referenceToUndefinedIdentifier(identifier: String)
  case identifierAlreadyDeclared(identifier: String)
}
