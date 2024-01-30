struct Parser {
  let tokens: [Token]
  private var position: Int = 0

  init(tokens: [Token]) {
    self.tokens = tokens
  }

  mutating func parse() throws -> (any Expression)? {
    let expression = try parseExpression()
    return expression
  }

  private func peek() -> Token? {
    return position < tokens.count ? tokens[position] : nil
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

  private mutating func parseIntLiteral() throws -> LiteralExpression<Int>? {
    guard let token = peek() else {
      return nil
    }

    guard token.type == .integerLiteral, let value = Int(token.value) else {
      throw ParserError.unexpectedTokenType(token: token, expected: [.integerLiteral])
    }

    _ = try? consume()

    return LiteralExpression<Int>(value: value)
  }

  private mutating func parseBooleanLiteral() throws -> LiteralExpression<Bool>? {
    guard let token = peek() else {
      return nil
    }

    guard token.type == .booleanLiteral, let value = Bool(token.value) else {
      throw ParserError.unexpectedTokenType(token: token, expected: [.booleanLiteral])
    }

    _ = try? consume()

    return LiteralExpression<Bool>(value: value)
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

  private mutating func parseFactor() throws -> (any Expression)? {
    guard let token = peek() else {
      return nil
    }

    if token.value == "(" {
      return try parseParenthesized()
    }

    if token.value == "if" {
      return try parseIfExpression()
    }

    switch token.type {
    case .integerLiteral:
      return try parseIntLiteral()
    case .booleanLiteral:
      return try parseBooleanLiteral()
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

  private mutating func parseTerm() throws -> (any Expression)? {
    guard var left = try parseFactor() else {
      return nil
    }

    while let op = peek(), ["*", "/"].contains(op.value) {
      _ = try? consume()
      guard let right = try parseFactor() else {
        throw ParserError.noTokenFound(precedingToken: op)
      }

      left = BinaryOpExpression(left: left, op: op.value, right: right)
    }

    return left
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

  private mutating func parseExpression() throws -> (any Expression)? {
    guard var left = try parseTerm() else {
      return nil
    }

    if let next = peek(), next.value == "(", let left = left as? IdentifierExpression {
      let parameters = try parseFunctionCallParameters()
      return FunctionCallExpression(identifier: left, arguments: parameters)
    }

    while let op = peek(), ["+", "-"].contains(op.value) {
      _ = try? consume()
      guard let right = try parseTerm() else {
        throw ParserError.noTokenFound(precedingToken: op)
      }

      left = BinaryOpExpression(left: left, op: op.value, right: right)
    }

    return left
  }
}
