struct Typechecker {
  var symTab: SymTab<Type> = SymTab()

  mutating func typecheck(_ expression: (any Expression)) throws -> Type {
    switch expression {
    case _ as LiteralExpression<Int>:
      return .int
    case _ as LiteralExpression<Bool>:
      return .bool
    case let binaryOpExpression as BinaryOpExpression:
      return try typecheckBinaryOpExpression(binaryOpExpression)
    case let identifierExpression as IdentifierExpression:
      return try typecheckIdentifierExpression(identifierExpression)
    case let varDeclarationExpression as VarDeclarationExpression:
      return try typecheckVarDeclarationExpression(varDeclarationExpression)
    default:
      fatalError("Unsupported")
    }
  }

  mutating private func typecheckBinaryOpExpression(_ expression: BinaryOpExpression) throws -> Type
  {
    let leftType = try typecheck(expression.left)
    let rightType = try typecheck(expression.right)

    if ["+", "-", "*", "/", "%", "<", "<=", ">", ">=", "==", "!="].contains(expression.op) {
      guard leftType == .int && rightType == .int else {
        throw TypecheckerError.inaproppriateType(expected: .int, got: [leftType, rightType])
      }
      return .int
    }

    if ["and", "or"].contains(expression.op) {
      guard leftType == .bool && rightType == .bool else {
        throw TypecheckerError.inaproppriateType(expected: .bool, got: [leftType, rightType])
      }
      return .bool
    }

    if expression.op == "=" {
      guard leftType == rightType else {
        throw TypecheckerError.inaproppriateType(expected: leftType, got: [rightType])
      }
      return .unit
    }

    throw TypecheckerError.unsupportedOperator(op: expression.op)
  }

  private func typecheckIdentifierExpression(_ expression: IdentifierExpression) throws -> Type {
    guard let type = symTab.lookup(expression.value) else {
      throw TypecheckerError.referenceToUndefinedIdentifier(identifier: expression.value)
    }

    return type
  }

  private mutating func typecheckVarDeclarationExpression(_ expression: VarDeclarationExpression)
    throws
    -> Type
  {
    let variableName = expression.variableIdentifier.value
    let type = try typecheck(expression.variableValue)
    if let typeDeclaration = expression.variableType {
      guard type == typeDeclaration else {
        throw TypecheckerError.inaproppriateType(expected: typeDeclaration, got: [type])
      }
    }

    guard symTab.lookup(variableName) == nil else {
      throw TypecheckerError.identifierAlreadyDeclared(
        identifier: expression.variableIdentifier.value)
    }

    symTab.insert(type, for: variableName)
    return .unit
  }

}
