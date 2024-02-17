struct Typechecker {
  var symTab: SymTab<Type> = SymTab()
  var funcTypesTab: SymTab<(params: [Type], returns: Type)> = SymTab(builtInFuncTypes)

  mutating func typecheck(_ expression: (any Expression)) throws -> any Expression {
    var expressionToReturn = expression
    switch expression {
    case _ as LiteralExpression<Int>:
      expressionToReturn.type = .int
      return expressionToReturn
    case _ as LiteralExpression<Bool>:
      expressionToReturn.type = .bool
      return expressionToReturn
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
      let typeOfExpression = type(of: expression)
      throw TypecheckerError.unknownExpressionType(
        type: "\(typeOfExpression)", location: expression.location
      )
    }
  }
}

extension Typechecker {

  mutating private func typecheckBinaryOpExpression(
    _ expression: BinaryOpExpression
  ) throws -> BinaryOpExpression {
    var typedExpression = expression
    typedExpression.left = try typecheck(expression.left)
    typedExpression.right = try typecheck(expression.right)

    if expression.op == "=" {
      guard typedExpression.left.type == typedExpression.right.type else {
        throw TypecheckerError.inaproppriateType(
          expected: [typedExpression.left.type], got: [typedExpression.right.type],
          location: expression.location
        )
      }
      typedExpression.type = .unit
      return typedExpression
    }

    guard let expectedTypes = funcTypesTab.lookup(expression.op) else {
      throw TypecheckerError.unsupportedOperator(op: expression.op, location: expression.location)
    }

    guard expectedTypes.params == [typedExpression.left.type, typedExpression.right.type] else {
      throw TypecheckerError.inaproppriateType(
        expected: expectedTypes.params,
        got: [typedExpression.left.type, typedExpression.right.type], location: expression.location
      )
    }

    typedExpression.type = expectedTypes.returns

    return typedExpression
  }

  private func typecheckIdentifierExpression(_ expression: IdentifierExpression) throws
    -> IdentifierExpression
  {
    var typedExpression = expression
    guard let type = symTab.lookup(expression.value) else {
      throw TypecheckerError.referenceToUndefinedIdentifier(
        identifier: expression.value, location: expression.location
      )
    }
    typedExpression.type = type
    return typedExpression
  }

  private mutating func typecheckVarDeclarationExpression(
    _ expression: VarDeclarationExpression
  ) throws -> VarDeclarationExpression {
    var typedExpression = expression
    let variableName = expression.variableIdentifier.value
    typedExpression.variableValue = try typecheck(expression.variableValue)
    typedExpression.variableIdentifier.type = typedExpression.variableValue.type

    if let typeDeclaration = expression.variableType {
      guard typedExpression.variableValue.type == typeDeclaration else {
        throw TypecheckerError.inaproppriateType(
          expected: [typeDeclaration], got: [typedExpression.variableValue.type],
          location: typedExpression.location)
      }
    }

    guard symTab.lookup(variableName) == nil else {
      throw TypecheckerError.identifierAlreadyDeclared(
        identifier: typedExpression.variableIdentifier.value,
        location: typedExpression.location
      )
    }

    symTab.insert(typedExpression.variableValue.type!, for: variableName)
    typedExpression.type = .unit
    return typedExpression
  }

  private mutating func typecheckBlockExpression(_ expression: BlockExpression) throws
    -> BlockExpression
  {
    var typedExpression = expression
    typedExpression.statements = try expression.statements.map { statement in
      try typecheck(statement)
    }

    if let resultExpression = typedExpression.resultExpression {
      typedExpression.resultExpression = try typecheck(resultExpression)
    }

    typedExpression.type = typedExpression.resultExpression?.type ?? .unit
    return typedExpression
  }

  private mutating func typecheckIfExpression(_ expression: IfExpression) throws
    -> IfExpression
  {
    var typedExpression = expression
    typedExpression.condition = try typecheck(typedExpression.condition)
    guard typedExpression.condition.type == .bool else {
      throw TypecheckerError.inaproppriateType(
        expected: [.bool], got: [typedExpression.condition.type],
        location: expression.condition.location
      )
    }

    typedExpression.thenExpression = try typecheck(typedExpression.thenExpression)

    if let elseExpression = typedExpression.elseExpression {
      typedExpression.elseExpression = try typecheck(elseExpression)
      guard typedExpression.thenExpression.type == typedExpression.elseExpression?.type else {
        throw TypecheckerError.inaproppriateType(
          expected: [typedExpression.thenExpression.type],
          got: [typedExpression.elseExpression?.type], location: expression.elseExpression?.location
        )
      }
    }

    typedExpression.type = typedExpression.thenExpression.type

    return typedExpression
  }

  private mutating func typecheckWhileExpression(_ expression: WhileExpression) throws
    -> WhileExpression
  {
    var typedExpression = expression
    typedExpression.condition = try typecheck(typedExpression.condition)
    guard typedExpression.condition.type == .bool else {
      throw TypecheckerError.inaproppriateType(
        expected: [.bool], got: [typedExpression.condition.type],
        location: expression.condition.location
      )
    }
    typedExpression.body = try typecheckBlockExpression(typedExpression.body)
    typedExpression.type = .unit
    return typedExpression
  }

  private mutating func typecheckNotExpression(_ expression: NotExpression) throws -> NotExpression
  {
    var typedExpression = expression
    typedExpression.value = try typecheck(typedExpression.value)

    guard typedExpression.value.type == .bool || typedExpression.value.type == .int else {
      throw TypecheckerError.inaproppriateType(
        expected: [.bool, .int], got: [typedExpression.value.type], location: expression.location
      )
    }
    typedExpression.type = typedExpression.value.type
    return typedExpression
  }

  private mutating func typecheckFunctionCallExpression(_ expression: FunctionCallExpression)
    throws
    -> FunctionCallExpression
  {
    var typedExpression = expression
    guard let expectedTypes = funcTypesTab.lookup(typedExpression.identifier.value) else {
      throw TypecheckerError.referenceToUndefinedIdentifier(
        identifier: typedExpression.identifier.value, location: expression.location
      )
    }

    guard expression.arguments.count == expectedTypes.params.count else {
      throw TypecheckerError.wrongNumberOfArguments(
        expected: expectedTypes.params.count, got: expression.arguments.count,
        location: expression.location
      )
    }

    typedExpression.arguments = try expression.arguments.enumerated().map { index, argument in
      let typedArgument = try typecheck(argument)
      guard typedArgument.type == expectedTypes.params[index] else {
        throw TypecheckerError.inaproppriateType(
          expected: [expectedTypes.params[index]], got: [typedArgument.type],
          location: argument.location
        )
      }
      return typedArgument
    }

    typedExpression.type = expectedTypes.returns
    return typedExpression
  }

}
