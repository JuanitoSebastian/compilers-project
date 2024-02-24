struct IrGenerator {
  let expressions: [any Expression]
  var instructions: [any Instruction] = []
  var symTab: SymTab<IrVar> = SymTab(irBuiltInFuncs)
  var varTypes: SymTab<Type> = SymTab()
  var nextVarNumber: Int = 0
  var labelNumbers: [String: Int] = [:]
  let unitVar = IrVar(name: "unit")

  init(expressions: [any Expression]) throws {
    self.expressions = expressions
    try self.varTypes.insert(.unit, for: unitVar)
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
    case let blockExpression as BlockExpression:
      return try handleBlockExpression(blockExpression)
    case let whileExpression as WhileExpression:
      return try handleWhileExpression(whileExpression)
    case let functionCallExpression as FunctionCallExpression:
      return try handleFunctionCallExpression(functionCallExpression)
    case let notExpression as NotExpression:
      return try handleNotExpression(notExpression)
    default:
      throw IrGeneratorError.unsupportedExpression(expression: node)
    }
  }

  private mutating func newVar(_ type: Type) throws -> IrVar {
    let varNumber = nextVarNumber
    nextVarNumber += 1
    let irVar = IrVar(name: "x\(varNumber)")
    try varTypes.insert(type, for: irVar)
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
    let irVar = try newVar(try unwrapType(literalExpression))
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
    guard let functionIrVar = symTab.lookup(binaryOpExpression.op) else {
      throw IrGeneratorError.referenceToUndefinedFunction(function: binaryOpExpression.op)
    }

    if binaryOpExpression.op == "and" {
      return try handleAndOp(binaryOpExpression)
    }

    if binaryOpExpression.op == "or" {
      return try handleOrOp(binaryOpExpression)
    }

    let left = try visit(binaryOpExpression.left)
    let right = try visit(binaryOpExpression.right)

    if binaryOpExpression.op == "=" {
      return handleAssignment(left, right, try unwrapLocation(binaryOpExpression))
    }

    let irVar = try newVar(try unwrapType(binaryOpExpression))
    let instruction = Call(
      function: functionIrVar,
      arguments: [left, right],
      destination: irVar,
      location: try unwrapLocation(binaryOpExpression)
    )
    instructions.append(instruction)
    return irVar
  }

  private mutating func handleAssignment(
    _ left: IrVar, _ right: IrVar, _ location: Location
  ) -> IrVar {
    let copyInstruction = Copy(
      source: right, destination: left,
      location: location
    )
    instructions.append(copyInstruction)
    return left
  }

  private mutating func handleAndOp(_ binaryOpExpression: BinaryOpExpression) throws -> IrVar {
    let location = try unwrapLocation(binaryOpExpression)
    let left = try visit(binaryOpExpression.left)
    let andRightLabel = newLabel(location, "and_right")
    let andSkipLabel = newLabel(location, "and_skip")
    let andEndLabel = newLabel(location, "and_end")

    let resultVar = try newVar(.bool)

    let condJump = CondJump(
      condition: left, thenLabel: andRightLabel, elseLabel: andSkipLabel,
      location: location
    )
    instructions.append(condJump)

    let jumpToEnd = Jump(label: andEndLabel, location: location)
    instructions.append(andRightLabel)
    let right = try visit(binaryOpExpression.right)
    let copyRightAsResult = Copy(
      source: right, destination: resultVar,
      location: location
    )
    instructions.append(copyRightAsResult)
    instructions.append(jumpToEnd)

    instructions.append(andSkipLabel)
    let loadInstructionToReesult = LoadConst(
      value: false, destination: resultVar, location: location)
    instructions.append(loadInstructionToReesult)
    instructions.append(andEndLabel)
    return resultVar
  }

  private mutating func handleOrOp(_ binaryOpExpression: BinaryOpExpression) throws -> IrVar {
    let location = try unwrapLocation(binaryOpExpression)
    let left = try visit(binaryOpExpression.left)
    let orRightLabel = newLabel(location, "or_right")
    let orSkipLabel = newLabel(location, "or_skip")
    let orEndLabel = newLabel(location, "or_end")

    let resultVar = try newVar(.bool)

    let condJump = CondJump(
      condition: left, thenLabel: orSkipLabel, elseLabel: orRightLabel,
      location: location
    )

    instructions.append(condJump)

    instructions.append(orRightLabel)
    let right = try visit(binaryOpExpression.right)
    let copyRightAsResult = Copy(
      source: right, destination: resultVar,
      location: location
    )
    instructions.append(copyRightAsResult)
    let jumpToEnd = Jump(label: orEndLabel, location: location)
    instructions.append(jumpToEnd)

    instructions.append(orSkipLabel)
    let loadInstructionToReesult = LoadConst(
      value: true, destination: resultVar, location: location
    )
    instructions.append(loadInstructionToReesult)
    instructions.append(jumpToEnd)

    instructions.append(orEndLabel)
    return resultVar
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
    let variableIrVar = try newVar(try unwrapType(varDeclarationExpression.variableValue))
    let copyInstruction = Copy(
      source: valueIrVar, destination: variableIrVar,
      location: try unwrapLocation(varDeclarationExpression)
    )
    try symTab.insert(variableIrVar, for: varDeclarationExpression.variableIdentifier.value)
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
      let ifResult = try newVar(.unit)
      let copyInstruction = Copy(
        source: unitVar, destination: ifResult,
        location: try unwrapLocation(ifExpression)
      )
      instructions.append(copyInstruction)
      return ifResult
    }
    let ifResult = try newVar(try unwrapType(ifExpression))
    let elseLabel = try newLabel(unwrapLocation(elseExpression), "else")
    let condJump = CondJump(
      condition: condVar, thenLabel: thenLabel, elseLabel: elseLabel,
      location: try unwrapLocation(ifExpression)
    )
    instructions.append(condJump)
    instructions.append(thenLabel)
    let thenResultVar = try visit(ifExpression.thenExpression)
    let copyInstructionThen = Copy(
      source: thenResultVar, destination: ifResult,
      location: try unwrapLocation(ifExpression)
    )
    let jumpToEnd = Jump(label: endLabel, location: try unwrapLocation(ifExpression.thenExpression))
    instructions.append(copyInstructionThen)
    instructions.append(jumpToEnd)
    instructions.append(elseLabel)
    let elseResultVar = try visit(elseExpression)
    let copyInstructionElse = Copy(
      source: elseResultVar, destination: ifResult,
      location: try unwrapLocation(ifExpression)
    )
    instructions.append(copyInstructionElse)
    instructions.append(endLabel)
    return unitVar
  }

  private mutating func handleBlockExpression(
    _ blockExpression: BlockExpression
  ) throws -> IrVar {
    symTab.push()
    varTypes.push()
    blockExpression.statements.forEach { _ = try? visit($0) }
    guard let resultExpression = blockExpression.resultExpression else {
      _ = try symTab.pop()
      _ = try varTypes.pop()
      return unitVar
    }
    let resultVar = try visit(resultExpression)
    _ = try symTab.pop()
    _ = try varTypes.pop()
    return resultVar
  }

  private mutating func handleWhileExpression(
    _ whileExpression: WhileExpression
  ) throws -> IrVar {
    let startLabel = try newLabel(unwrapLocation(whileExpression), "while_start")
    instructions.append(startLabel)

    let bodyLabel = try newLabel(unwrapLocation(whileExpression), "while_body")
    let endLabel = try newLabel(unwrapLocation(whileExpression), "while_end")

    let conditionVar = try visit(whileExpression.condition)
    let condJump = CondJump(
      condition: conditionVar, thenLabel: bodyLabel, elseLabel: endLabel,
      location: try unwrapLocation(whileExpression)
    )
    instructions.append(condJump)

    instructions.append(bodyLabel)
    _ = try visit(whileExpression.body)
    let jumpToStart = Jump(label: startLabel, location: try unwrapLocation(whileExpression.body))
    instructions.append(jumpToStart)
    instructions.append(endLabel)
    return unitVar
  }

  private mutating func handleFunctionCallExpression(
    _ functionCallExpression: FunctionCallExpression
  ) throws -> IrVar {
    guard let functionIrVar = symTab.lookup(functionCallExpression.identifier.value) else {
      throw IrGeneratorError.referenceToUndefinedFunction(
        function: functionCallExpression.identifier.value
      )
    }
    let params = try functionCallExpression.arguments.map { try visit($0) }
    let functionCallIrVar = try newVar(try unwrapType(functionCallExpression))
    let functionCall = Call(
      function: functionIrVar,
      arguments: params,
      destination: functionCallIrVar,
      location: try unwrapLocation(functionCallExpression)
    )
    instructions.append(functionCall)
    return functionCallIrVar
  }

  private mutating func handleNotExpression(
    _ notExpression: NotExpression
  ) throws -> IrVar {
    guard let notFunction = symTab.lookup("unary_not") else {
      throw IrGeneratorError.referenceToUndefinedFunction(function: "not")
    }
    let valueVar = try visit(notExpression.value)
    let notVar = try newVar(try unwrapType(notExpression))
    let notCall = Call(
      function: notFunction,
      arguments: [valueVar],
      destination: notVar,
      location: try unwrapLocation(notExpression)
    )
    instructions.append(notCall)
    return notVar
  }
}
