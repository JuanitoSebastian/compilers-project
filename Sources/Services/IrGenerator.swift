struct IrGenerator {
  let expressions: [any Expression]
  var instructions: [any Instruction] = []
  var symTab: SymTab<IrVar> = SymTab(irBuiltInFuncs)
  var varTypes: SymTab<Type> = SymTab()
  var nextVarNumber: Int = 0
  var labelNumbers: [String: Int] = [:]
  let unitVar = IrVar(name: "unit")

  init(expressions: [any Expression]) {
    self.expressions = expressions
    self.varTypes.insert(.unit, for: unitVar)
  }

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
    case let ifExpression as IfExpression:
      return try handleIfExpression(ifExpression)
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

  private mutating func newLabel(_ location: Location, _ labelFor: String? = nil) -> Label {
    let labelKey = labelFor ?? "none"
    let count = labelNumbers[labelKey] ?? 1
    let labelText =
      labelFor == nil
      ? "L\(count)"
      : "\(labelKey)\(count)"
    labelNumbers[labelKey] = count + 1
    return Label(label: "\(labelText)", location: location)
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
    guard let functionIrVar = symTab.lookup(binaryOpExpression.op) else {
      throw IrGeneratorError.referenceToUndefinedFunction(binaryOpExpression: binaryOpExpression)
    }
    let instruction = Call(
      function: functionIrVar,
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

  private mutating func handleIfExpression(
    _ ifExpression: IfExpression
  ) throws -> IrVar {
    let thenLabel = try newLabel(unwrapLocation(ifExpression.thenExpression), "then")
    let endLabel = try newLabel(unwrapLocation(ifExpression), "if_end")
    let condVar = try visit(ifExpression.condition)

    guard let elseExpression = ifExpression.elseExpression else {
      let condJump = CondJump(
        condition: condVar, thenLabel: thenLabel, elseLabel: endLabel,
        location: try unwrapLocation(ifExpression)
      )
      instructions.append(condJump)
      instructions.append(thenLabel)
      _ = try visit(ifExpression.thenExpression)
      instructions.append(endLabel)
      return unitVar
    }

    let elseLabel = try newLabel(unwrapLocation(elseExpression), "else")
    let condJump = CondJump(
      condition: condVar, thenLabel: thenLabel, elseLabel: elseLabel,
      location: try unwrapLocation(ifExpression)
    )
    instructions.append(condJump)
    instructions.append(thenLabel)
    _ = try visit(ifExpression.thenExpression)
    let jumpToEnd = Jump(label: endLabel, location: try unwrapLocation(ifExpression.thenExpression))
    instructions.append(jumpToEnd)
    instructions.append(elseLabel)
    _ = try visit(elseExpression)
    instructions.append(endLabel)
    return unitVar
  }
}
