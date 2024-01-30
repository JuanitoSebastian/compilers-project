struct Parser {
  let tokens: [Token]
  private var position: Int = 0

  init(tokens: [Token]) {
    self.tokens = tokens
  }

  func peek() -> Token? {
    return position < tokens.count ? tokens[position] : nil
  }

  mutating func parse() throws -> (any Expression)? {
    let expression = try parseExpression()
    return expression
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

  private mutating func parseFactor() throws -> (any Expression)? {
    guard let token = peek() else {
      return nil
    }

    if token.value == "(" {
      return try parseParenthesized()
    }

    switch token.type {
    case .integerLiteral:
      return try parseIntLiteral()
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

  private mutating func parseExpression() throws -> (any Expression)? {
    guard var left = try parseTerm() else {
      return nil
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
