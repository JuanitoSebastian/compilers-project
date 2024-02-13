struct Typechecker {
  var symTab: SymTab<Type> = SymTab()
  var funcTypesTab: SymTab<(params: [Type], returns: Type)> = SymTab(builtInFuncTypes)

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
    case let blockExpression as BlockExpression:
      return try typecheckBlockExpression(blockExpression)
    case let ifExpression as IfExpression:
      return try typecheckIfExpression(ifExpression)
    case let whileExpression as WhileExpression:
      return try typecheckWhileExpression(whileExpression)
    case let notExpression as NotExpression:
      return try typecheckNotExpression(notExpression)
    case let functionCallExpression as FunctionCallExpression:
      return try typecheckFunctionCallExpression(functionCallExpression)
    default:
      fatalError("Unsupported expression type: \(type(of: expression))")
    }
  }
}

extension Typechecker {
  mutating private func typecheckBinaryOpExpression(
    _ expression: BinaryOpExpression
  ) throws -> Type {
    let leftType = try typecheck(expression.left)
    let rightType = try typecheck(expression.right)

    if expression.op == "=" {
      guard leftType == rightType else {
        throw TypecheckerError.inaproppriateType(expected: [leftType], got: [rightType])
      }
      return .unit
    }

    guard let expectedTypes = funcTypesTab.lookup(expression.op) else {
      throw TypecheckerError.unsupportedOperator(op: expression.op)
    }

    guard expectedTypes.params == [leftType, rightType] else {
      throw TypecheckerError.inaproppriateType(
        expected: expectedTypes.params, got: [leftType, rightType]
      )
    }

    return expectedTypes.returns
  }

  private func typecheckIdentifierExpression(_ expression: IdentifierExpression) throws -> Type {
    guard let type = symTab.lookup(expression.value) else {
      throw TypecheckerError.referenceToUndefinedIdentifier(identifier: expression.value)
    }

    return type
  }

  private mutating func typecheckVarDeclarationExpression(
    _ expression: VarDeclarationExpression
  ) throws -> Type {
    let variableName = expression.variableIdentifier.value
    let type = try typecheck(expression.variableValue)
    if let typeDeclaration = expression.variableType {
      guard type == typeDeclaration else {
        throw TypecheckerError.inaproppriateType(expected: [typeDeclaration], got: [type])
      }
    }

    guard symTab.lookup(variableName) == nil else {
      throw TypecheckerError.identifierAlreadyDeclared(
        identifier: expression.variableIdentifier.value)
    }

    symTab.insert(type, for: variableName)
    return .unit
  }

  private mutating func typecheckBlockExpression(_ expression: BlockExpression) throws -> Type {
    for statement in expression.statements {
      _ = try typecheck(statement)
    }

    if let resultExpression = expression.resultExpression {
      return try typecheck(resultExpression)
    }

    return .unit
  }

  private mutating func typecheckIfExpression(_ expression: IfExpression) throws -> Type {
    let conditionType = try typecheck(expression.condition)
    guard conditionType == .bool else {
      throw TypecheckerError.inaproppriateType(expected: [.bool], got: [conditionType])
    }

    let thenType = try typecheck(expression.thenExpression)

    if let elseExpression = expression.elseExpression {
      let elseType = try typecheck(elseExpression)
      guard thenType == elseType else {
        throw TypecheckerError.inaproppriateType(expected: [thenType], got: [elseType])
      }
    }

    return thenType
  }

  private mutating func typecheckWhileExpression(_ expression: WhileExpression) throws -> Type {
    let conditionType = try typecheck(expression.condition)
    guard conditionType == .bool else {
      throw TypecheckerError.inaproppriateType(expected: [.bool], got: [conditionType])
    }

    _ = try typecheck(expression.body)
    return .unit
  }

  private mutating func typecheckNotExpression(_ expression: NotExpression) throws -> Type {
    let type = try typecheck(expression.value)

    guard type == .bool || type == .int else {
      throw TypecheckerError.inaproppriateType(expected: [.bool, .int], got: [type])
    }

    return type
  }

  private mutating func typecheckFunctionCallExpression(_ expression: FunctionCallExpression) throws
    -> Type
  {
    guard let expectedTypes = funcTypesTab.lookup(expression.identifier.value) else {
      throw TypecheckerError.referenceToUndefinedIdentifier(identifier: expression.identifier.value)
    }

    guard expression.arguments.count == expectedTypes.params.count else {
      throw TypecheckerError.wrongNumberOfArguments(
        expected: expectedTypes.params.count, got: expression.arguments.count
      )
    }

    for (index, argument) in expression.arguments.enumerated() {
      let argumentType = try typecheck(argument)
      guard argumentType == expectedTypes.params[index] else {
        throw TypecheckerError.inaproppriateType(
          expected: [expectedTypes.params[index]], got: [argumentType])
      }
    }

    return expectedTypes.returns
  }

}
