struct IrGenerator {
  let expressions: [any Expression]
  var instructions: [any Instruction]
  var symTab: SymTab<IrVar> = SymTab()
  var varTypes: SymTab<Type> = SymTab()
  var nextVarNumber: Int = 0

  mutating func generate() throws {
    for expression in expressions {
      _ = try visit(expression)
    }
  }

  private mutating func visit(_ node: any Expression) throws -> IrVar {
    switch node {
    case let literalInt as LiteralExpression<Int>:
      return try handleLiteralExpression(literalInt)
    case let literalBool as LiteralExpression<Bool>:
      return try handleLiteralExpression(literalBool)
    case let binary as BinaryOpExpression:
      return try handleBinaryOpExpression(binary)
    case let varExpression as VarDeclarationExpression:
      return try handleVarDeclarationExpression(varExpression)
    case let identifierExpression as IdentifierExpression:
      return try handleIdentifierExpression(identifierExpression)
    default:
      fatalError("Unimplemented expression: \(node)")
    }
  }

  private mutating func newVar(_ type: Type) -> IrVar {
    let varNumber = nextVarNumber
    nextVarNumber += 1
    let irVar = IrVar(name: "x\(varNumber)")
    varTypes.insert(type, for: irVar)
    return irVar
  }

  private func unwrapLocation(_ expression: any Expression) throws -> Location {
    guard let location = expression.location else {
      throw IrGeneratorError.missingLocation(expression: expression)
    }
    return location
  }

  private func unwrapType(_ expression: any Expression) throws -> Type {
    guard let type = expression.type else {
      throw IrGeneratorError.missingType(expression: expression)
    }
    return type
  }
}

extension IrGenerator {
  private mutating func handleLiteralExpression<T: LiteralExpressionValue>(
    _ literalExpression: LiteralExpression<T>
  ) throws -> IrVar {
    let irVar = newVar(try unwrapType(literalExpression))
    let instruction = LoadConst<T>(
      value: literalExpression.value, destination: irVar,
      location: try unwrapLocation(literalExpression)
    )
    instructions.append(instruction)
    return irVar
  }

  private mutating func handleBinaryOpExpression(
    _ binaryOpExpression: BinaryOpExpression
  ) throws -> IrVar {
    let left = try visit(binaryOpExpression.left)
    let right = try visit(binaryOpExpression.right)
    let irVar = newVar(try unwrapType(binaryOpExpression))
    let instruction = Call(
      function: IrVar(name: binaryOpExpression.op),
      arguments: [left, right],
      destination: irVar,
      location: try unwrapLocation(binaryOpExpression)
    )
    instructions.append(instruction)
    return irVar
  }

  private mutating func handleVarDeclarationExpression(
    _ varDeclarationExpression: VarDeclarationExpression
  ) throws -> IrVar {
    guard symTab.lookup(varDeclarationExpression.variableIdentifier.value) == nil else {
      throw IrGeneratorError.duplicateVarDeclaration(
        varDeclarationExpression: varDeclarationExpression
      )
    }

    let valueIrVar = try visit(varDeclarationExpression.variableValue)
    let variableIrVar = newVar(try unwrapType(varDeclarationExpression.variableValue))
    let copyInstruction = Copy(
      source: valueIrVar, destination: variableIrVar,
      location: try unwrapLocation(varDeclarationExpression)
    )
    symTab.insert(variableIrVar, for: varDeclarationExpression.variableIdentifier.value)
    instructions.append(copyInstruction)
    return variableIrVar
  }

  private func handleIdentifierExpression(
    _ identifierExpression: IdentifierExpression
  ) throws -> IrVar {
    guard let irVar = symTab.lookup(identifierExpression.value) else {
      throw IrGeneratorError.referenceToUndefinedVar(identifier: identifierExpression)
    }
    return irVar
  }
}
