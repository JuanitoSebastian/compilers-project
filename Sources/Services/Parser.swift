struct Parser {
  let tokens: [Token]
  private var position: Int = 0

  init(tokens: [Token]) {
    self.tokens = tokens
  }

  mutating func parse() throws -> BlockExpression {
    return try parseBlockExpression(topLevel: true)
  }

  private func peek(_ positionToPeek: Int? = nil) -> Token? {
    let index = positionToPeek ?? position
    return tokens.indices.contains(index) ? tokens[index] : nil
  }

  private mutating func consume(_ expected: String...) throws -> Token {
    guard let token = peek() else {
      throw ParserError.noTokenFound(precedingToken: peek(position - 1))
    }

    if expected.count > 0 && !expected.contains(token.value) {
      throw ParserError.unexpectedTokenValue(token: token, expected: expected)
    }

    position += 1
    return token
  }

  private mutating func consume(_ exptected: TokenType) throws -> Token {
    guard let token = peek() else {
      throw ParserError.noTokenFound(precedingToken: peek(position - 1))
    }

    if token.type != exptected {
      throw ParserError.unexpectedTokenType(token: token, expected: [exptected])
    }

    position += 1
    return token
  }

  private mutating func parseFactor() throws -> (any Expression)? {
    guard let token = peek() else {
      return nil
    }

    if ["not", "-"].contains(token.value) {
      return try parseNotExpression()
    }

    if token.value == "(" {
      return try parseParenthesized()
    }

    if token.value == "if" {
      return try parseIfExpression()
    }

    if token.value == "{" {
      return try parseBlockExpression()
    }

    switch token.type {
    case .integerLiteral:
      _ = try consume(token.value)
      let literal: LiteralExpression<Int> = try parseLiteral(token)
      return literal
    case .booleanLiteral:
      _ = try consume(token.value)
      let literal: LiteralExpression<Bool> = try parseLiteral(token)
      return literal
    case .identifier:
      _ = try consume(token.value)
      return try parseIdentifier(token)
    default:
      throw ParserError.unexpectedTokenType(token: token, expected: [.integerLiteral, .identifier])
    }
  }

  private mutating func parseParenthesized() throws -> (any Expression)? {
    _ = try consume("(")
    let expression = try parseExpression()
    _ = try consume(")")
    return expression
  }

  private mutating func parseFunctionCallParameters() throws -> [(any Expression)] {
    var expressions: [(any Expression)] = []
    _ = try consume("(")
    while let token = peek(), token.value != ")" {
      if let expression = try parseExpression() {
        expressions.append(expression)
      }
    }
    _ = try consume(")")
    return expressions
  }

  private mutating func parseExpression(
    _ depth: Int = 0, previousExpression: (any Expression)? = nil
  ) throws -> (any Expression)? {

    guard let left = previousExpression != nil ? previousExpression : try parseFactor() else {
      return nil
    }

    for (offset, operators) in leftAssociativeBinaryOperators.enumerated().dropFirst(depth) {
      while let op = peek(), operators.contains(op.value) {
        _ = try? consume()
        guard let right = try parseExpression(offset + 1) else {
          throw ParserError.noTokenFound(precedingToken: op)
        }

        let location = try Location.combineLocations(
          lhs: left.location, rhs: right.location
        )

        return try parseExpression(
          previousExpression: BinaryOpExpression(
            left: left, op: op.value, right: right, location: location)
        )
      }
    }

    if let left = left as? IdentifierExpression {
      if left.value == "var" {
        return try parseVarDeclaration(varIdentifier: left)
      }

      if left.value == "while" {
        return try parseWhileExpression(whileIdenfitier: left)
      }
      if let next = peek(), next.value == "(" {
        let parameters = try parseFunctionCallParameters()
        let location = try Location.combineLocations(
          lhs: left.location, rhs: parameters.last?.location
        )
        return FunctionCallExpression(identifier: left, arguments: parameters, location: location)
      }
    }

    return left
  }
}

// Functions for specific Expression types
extension Parser {

  private mutating func parseBlockExpression(topLevel: Bool = false) throws -> BlockExpression {
    var startToken: Token?
    var endToken: Token?

    if !topLevel {
      startToken = try consume("{")
    } else {
      startToken = peek()
    }

    var statements: [(any Expression)] = []
    var resultExpression: (any Expression)?
    var previousResultWasBlock = false

    while let token = peek(), token.value != "}" {
      if let expression = try parseExpression() {
        if let nextToken = peek(), nextToken.value == ";" {
          statements.append(expression)
          _ = try consume(";")
          continue
        } else {
          // Semicolons optional after blocks
          if let previousResultExpression = resultExpression {
            guard previousResultWasBlock else {
              throw ParserError.missingSemicolon(token: token)
            }
            statements.append(previousResultExpression)
          }
          resultExpression = expression
          previousResultWasBlock = peek(position - 1)?.value == "}"
        }
      }
    }

    if !topLevel {
      endToken = try consume("}")
    } else {
      endToken = peek(position - 1)
    }

    let location = try Location.combineLocations(
      lhs: startToken?.location, rhs: endToken?.location
    )
    return BlockExpression(
      statements: statements, resultExpression: resultExpression, location: location
    )
  }

  private mutating func parseWhileExpression(
    whileIdenfitier: IdentifierExpression
  ) throws -> WhileExpression {
    guard let condition = try parseExpression() else {
      throw ParserError.whileExpressionMissingCondition
    }

    _ = try consume("do")

    let body = try parseBlockExpression()
    let location = try Location.combineLocations(lhs: whileIdenfitier.location, rhs: body.location)

    return WhileExpression(condition: condition, body: body, location: location)
  }

  private mutating func parseVarDeclaration(
    varIdentifier: IdentifierExpression
  ) throws -> VarDeclarationExpression {
    let variableName = try parseIdentifier(consume(.identifier))

    var variableType: Type?
    if let token = peek(), token.value == ":" {
      _ = try consume()
      let typeIdentifierExpression = try parseIdentifier(consume(.identifier))
      switch typeIdentifierExpression.value {
      case "Int":
        variableType = .int
      case "Bool":
        variableType = .bool
      default:
        throw ParserError.varDeclarationUnknownType(
          varIdentifierExpression: typeIdentifierExpression
        )
      }
    }

    _ = try consume("=")

    guard let valueExpression = try parseExpression(1) else {
      throw ParserError.varDeclarationMissingExpression(varIdentifierExpression: varIdentifier)
    }

    let location = try Location.combineLocations(
      lhs: varIdentifier.location, rhs: valueExpression.location)

    return VarDeclarationExpression(
      variableIdentifier: variableName, variableValue: valueExpression, variableType: variableType,
      location: location
    )
  }

  /// Parses a not expresison. Chained nots are parsed as a single not expression.
  /// - Returns: A not expression or the nots cancel out
  private mutating func parseNotExpression() throws -> (any Expression)? {
    var not = false
    var latestToken: Token?
    while let token = peek() {
      latestToken = token
      if ["not", "-"].contains(token.value) {
        _ = try consume()
        not = !not
      } else {
        break
      }
    }

    guard let value = try parseFactor() else {
      throw ParserError.noTokenFound(precedingToken: latestToken)
    }

    let location = try Location.combineLocations(lhs: latestToken?.location, rhs: value.location)

    return not ? NotExpression(value: value, location: location) : value
  }

  /// Parses a literal expression. Currently supported Int and Bool literals.
  private mutating func parseLiteral<T: LiteralExpressionValue>(_ token: Token) throws
    -> LiteralExpression<T>
  {
    guard let value = T(token.value) else {
      throw ParserError.failedToParseLiteralValue(
        token: token, triedToParse: String(describing: T.self)
      )
    }

    return LiteralExpression<T>(value: value, location: token.location)
  }

  private mutating func parseIdentifier(_ token: Token) throws -> IdentifierExpression {
    guard token.type == .identifier else {
      throw ParserError.unexpectedTokenType(token: token, expected: [.identifier])
    }

    return IdentifierExpression(value: token.value, location: token.location)
  }

  private mutating func parseIfExpression() throws -> IfExpression {
    let ifIdentifier = try consume("if")
    guard let condition = try parseExpression() else {
      throw ParserError.ifExpressionMissingCondition(ifIdentifierToken: ifIdentifier)
    }

    _ = try consume("then")
    guard let thenExpression = try parseExpression() else {
      throw ParserError.ifExpressionMissingThenExpression(ifIdentifierToken: ifIdentifier)
    }

    if let token = peek(), token.value == "else" {
      _ = try consume("else")
      let elseExpression = try parseExpression()
      let location = try Location.combineLocations(
        lhs: ifIdentifier.location, rhs: elseExpression?.location
      )
      return IfExpression(
        condition: condition,
        thenExpression: thenExpression,
        elseExpression: elseExpression,
        location: location
      )
    }

    let location = try Location.combineLocations(
      lhs: ifIdentifier.location, rhs: thenExpression.location
    )

    return IfExpression(
      condition: condition,
      thenExpression: thenExpression,
      elseExpression: nil,
      location: location
    )
  }
}
