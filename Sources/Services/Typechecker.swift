struct Typechecker {
  var symTab: SymTab<Type> = SymTab()
  var funcTypesTab: SymTab<(params: [Type], returns: Type)> = SymTab(builtInFuncTypes)

  mutating func typecheck(_ expression: (any Expression)) throws -> (any Expression) {
    var expression = expression
    _ = try getAndSetTypes(&expression)
    return expression
  }
}

extension Typechecker {
  mutating private func getAndSetTypes(_ expression: inout (any Expression)) throws -> Type {
    switch expression {
    case _ as LiteralExpression<Int>:
      expression.type = .int
      return .int
    case _ as LiteralExpression<Bool>:
      expression.type = .bool
      return .bool
    case var binaryOpExpression as BinaryOpExpression:
      let type = try typecheckBinaryOpExpression(&binaryOpExpression)
      expression.type = type
      return type
    case var identifierExpression as IdentifierExpression:
      let type = try typecheckIdentifierExpression(&identifierExpression)
      expression.type = type
      return type
    case var varDeclarationExpression as VarDeclarationExpression:
      let type = try typecheckVarDeclarationExpression(&varDeclarationExpression)
      expression.type = type
      return type
    case var blockExpression as BlockExpression:
      let type = try typecheckBlockExpression(&blockExpression)
      expression.type = type
      return type
    case var ifExpression as IfExpression:
      let type = try typecheckIfExpression(&ifExpression)
      expression.type = type
      return type
    case var whileExpression as WhileExpression:
      let type = try typecheckWhileExpression(&whileExpression)
      expression.type = type
      return type
    case var notExpression as NotExpression:
      let type = try typecheckNotExpression(&notExpression)
      expression.type = type
      return type
    case var functionCallExpression as FunctionCallExpression:
      let type = try typecheckFunctionCallExpression(&functionCallExpression)
      expression.type = type
      return type
    default:
      let typeOfExpression = type(of: expression)
      throw TypecheckerError.unknownExpressionType(type: "\(typeOfExpression)")
    }
  }

  mutating private func typecheckBinaryOpExpression(
    _ expression: inout BinaryOpExpression
  ) throws -> Type {
    let leftType = try getAndSetTypes(&expression.left)
    let rightType = try getAndSetTypes(&expression.right)

    if expression.op == "=" {
      guard leftType == rightType else {
        throw TypecheckerError.inaproppriateType(
          expected: [leftType], got: [rightType], location: expression.location
        )
      }
      return .unit
    }

    guard let expectedTypes = funcTypesTab.lookup(expression.op) else {
      throw TypecheckerError.unsupportedOperator(op: expression.op, location: expression.location)
    }

    guard expectedTypes.params == [leftType, rightType] else {
      throw TypecheckerError.inaproppriateType(
        expected: expectedTypes.params, got: [leftType, rightType], location: expression.location
      )
    }

    return expectedTypes.returns
  }

  private func typecheckIdentifierExpression(_ expression: inout IdentifierExpression) throws
    -> Type
  {
    guard let type = symTab.lookup(expression.value) else {
      throw TypecheckerError.referenceToUndefinedIdentifier(
        identifier: expression.value, location: expression.location
      )
    }

    return type
  }

  private mutating func typecheckVarDeclarationExpression(
    _ expression: inout VarDeclarationExpression
  ) throws -> Type {
    let variableName = expression.variableIdentifier.value
    let type = try getAndSetTypes(&expression.variableValue)
    if let typeDeclaration = expression.variableType {
      guard type == typeDeclaration else {
        throw TypecheckerError.inaproppriateType(
          expected: [typeDeclaration], got: [type], location: expression.location)
      }
    }

    guard symTab.lookup(variableName) == nil else {
      throw TypecheckerError.identifierAlreadyDeclared(
        identifier: expression.variableIdentifier.value,
        location: expression.location
      )
    }

    symTab.insert(type, for: variableName)
    return .unit
  }

  private mutating func typecheckBlockExpression(_ expression: inout BlockExpression) throws -> Type
  {
    for var statement in expression.statements {
      _ = try getAndSetTypes(&statement)
    }

    if var resultExpression = expression.resultExpression {
      return try getAndSetTypes(&resultExpression)
    }

    return .unit
  }

  private mutating func typecheckIfExpression(_ expression: inout IfExpression) throws -> Type {
    let conditionType = try getAndSetTypes(&expression.condition)
    guard conditionType == .bool else {
      throw TypecheckerError.inaproppriateType(
        expected: [.bool], got: [conditionType], location: expression.condition.location
      )
    }

    let thenType = try getAndSetTypes(&expression.thenExpression)

    if var elseExpression = expression.elseExpression {
      let elseType = try getAndSetTypes(&elseExpression)
      guard thenType == elseType else {
        throw TypecheckerError.inaproppriateType(
          expected: [thenType], got: [elseType], location: expression.elseExpression?.location
        )
      }
    }

    return thenType
  }

  private mutating func typecheckWhileExpression(_ expression: inout WhileExpression) throws -> Type
  {
    let conditionType = try getAndSetTypes(&expression.condition)
    guard conditionType == .bool else {
      throw TypecheckerError.inaproppriateType(
        expected: [.bool], got: [conditionType], location: expression.condition.location
      )
    }
    var body = expression.body as (any Expression)
    _ = try getAndSetTypes(&body)
    return .unit
  }

  private mutating func typecheckNotExpression(_ expression: inout NotExpression) throws -> Type {
    let type = try getAndSetTypes(&expression.value)

    guard type == .bool || type == .int else {
      throw TypecheckerError.inaproppriateType(
        expected: [.bool, .int], got: [type], location: expression.location
      )
    }

    return type
  }

  private mutating func typecheckFunctionCallExpression(_ expression: inout FunctionCallExpression)
    throws
    -> Type
  {
    guard let expectedTypes = funcTypesTab.lookup(expression.identifier.value) else {
      throw TypecheckerError.referenceToUndefinedIdentifier(
        identifier: expression.identifier.value, location: expression.location
      )
    }

    guard expression.arguments.count == expectedTypes.params.count else {
      throw TypecheckerError.wrongNumberOfArguments(
        expected: expectedTypes.params.count, got: expression.arguments.count
      )
    }

    for (index, var argument) in expression.arguments.enumerated() {
      let argumentType = try getAndSetTypes(&argument)
      guard argumentType == expectedTypes.params[index] else {
        throw TypecheckerError.inaproppriateType(
          expected: [expectedTypes.params[index]], got: [argumentType],
          location: expression.location)
      }
    }

    return expectedTypes.returns
  }

}
