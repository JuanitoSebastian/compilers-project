struct Parser {
  let tokens: [Token]
  private var position: Int = 0
  private var isInsideBlock = false

  init(tokens: [Token]) {
    self.tokens = tokens
  }

  mutating func parse() throws -> [(any Expression)?] {
    var expressions: [(any Expression)?] = []
    while position < tokens.count {
      expressions.append(try parseExpression())
    }
    return expressions
  }

  private func peek(_ positionToPeek: Int? = nil) -> Token? {
    let index = positionToPeek ?? position
    return index < tokens.count ? tokens[index] : nil
  }

  private mutating func consume(_ expected: String...) throws -> Token? {
    guard let token = peek() else {
      return nil
    }

    if expected.count > 0 && !expected.contains(token.value) {
      throw ParserError.unexpectedTokenValue(token: token, expected: expected)
    }

    position += 1
    return token
  }

  private mutating func parseFactor() throws -> (any Expression)? {
    guard let token = peek() else {
      return nil
    }

    if token.value == "not" {
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
      let literal: LiteralExpression<Int> = try parseLiteral(token.type)
      return literal
    case .booleanLiteral:
      let literal: LiteralExpression<Bool> = try parseLiteral(token.type)
      return literal
    case .identifier:
      return try parseIdentifier()
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

        return try parseExpression(
          previousExpression: BinaryOpExpression(left: left, op: op.value, right: right))
      }
    }

    if let left = left as? IdentifierExpression {
      if left.value == "var" {
        return try parseVarDeclaration()
      }

      if let next = peek(), next.value == "(" {
        let parameters = try parseFunctionCallParameters()
        return FunctionCallExpression(identifier: left, arguments: parameters)
      }
    }

    return left
  }
}

// Functions for specific Expression types
extension Parser {

  private mutating func parseBlockExpression() throws -> BlockExpression {
    // TODO: Make this better and more readable
    _ = try consume("{")
    let alreadyInBlock = isInsideBlock
    isInsideBlock = true
    var expressions: [(any Expression)] = []
    var resultExpression: (any Expression)?
    while let token = peek(), token.value != "}" {
      if let expression = try parseExpression() {
        expressions.append(expression)
        if let nextToken = peek(), nextToken.value == ";" {
          _ = try consume(";")
          continue
        } else if peek() != nil && peek(position - 1)?.value != "}" {
          guard resultExpression == nil else {
            throw ParserError.missingSemicolon(token: token)
          }
          resultExpression = expression
        }
      }
    }

    if !alreadyInBlock {
      isInsideBlock = false
    }

    _ = try consume("}")
    return BlockExpression(statements: expressions, resultExpression: resultExpression)
  }

  private mutating func parseVarDeclaration() throws -> VarDeclarationExpression {
    guard isInsideBlock else {
      throw ParserError.varDeclarationOutsideBlock()
    }

    guard let expression = try parseExpression() as? BinaryOpExpression else {
      throw ParserError.varDeclarationMissingExpression()
    }

    return VarDeclarationExpression(declaration: expression)
  }

  /// Parses a not expresison. Chained nots are parsed as a single not expression.
  /// - Returns: A not expression or the nots cancel out
  private mutating func parseNotExpression() throws -> (any Expression)? {
    var not = false
    var latestToken: Token?
    while let token = peek() {
      latestToken = token
      if token.value == "not" {
        _ = try consume()
        not = !not
      } else {
        break
      }
    }

    guard let value = try parseFactor() else {
      throw ParserError.noTokenFound(precedingToken: latestToken)
    }

    return not ? NotExpression(value: value) : value
  }

  /// Parses a literal expression. Currently supported Int and Bool literals.
  private mutating func parseLiteral<T: LiteralExpressionValue>(_ expected: TokenType) throws
    -> LiteralExpression<T>
  {
    guard let token = peek() else {
      throw ParserError.noTokenFound(precedingToken: nil)
    }

    guard let value = T(token.value) else {
      throw ParserError.unexpectedTokenType(token: token, expected: [expected])
    }

    _ = try? consume()

    return LiteralExpression<T>(value: value)
  }

  private mutating func parseIdentifier() throws -> IdentifierExpression? {
    guard let token = peek() else {
      return nil
    }

    guard token.type == .identifier else {
      throw ParserError.unexpectedTokenType(token: token, expected: [.identifier])
    }

    _ = try? consume()

    return IdentifierExpression(value: token.value)
  }

  private mutating func parseIfExpression() throws -> IfExpression {
    _ = try consume("if")
    guard let condition = try parseExpression() else {
      throw ParserError.ifExpressionMissingCondition
    }

    _ = try consume("then")
    guard let thenExpression = try parseExpression() else {
      throw ParserError.ifExpressionMissingThenExpression
    }

    var elseExpression: (any Expression)?

    if let token = peek(), token.value == "else" {
      _ = try consume("else")
      elseExpression = try parseExpression()
    }

    return IfExpression(
      condition: condition,
      thenExpression: thenExpression,
      elseExpression: elseExpression)
  }
}
