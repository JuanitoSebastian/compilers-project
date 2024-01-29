struct Parser {
  let tokens: [Token]
  var position: Int = 0

  func peek() -> Token? {
    return position < tokens.count ? tokens[position] : nil
  }

  mutating func consume(_ expected: String...) throws -> Token? {
    guard let token = peek() else {
      return nil
    }

    if expected.count > 0 && !expected.contains(token.value) {
      throw ParserError.unexpectedTokenValue(token: token, expected: expected)
    }

    position += 1
    return token
  }

  mutating func parseIntLiteral() throws -> LiteralExpression<Int>? {
    guard let token = peek() else {
      return nil
    }

    guard token.type == .integerLiteral, let value = Int(token.value) else {
      throw ParserError.unexpectedTokenType(token: token, expected: .integerLiteral)
    }

    _ = try? consume()

    return LiteralExpression<Int>(value: value)
  }

  mutating func parseIdentifier() throws -> IdentifierExpression? {
    guard let token = peek() else {
      return nil
    }

    guard token.type == .identifier else {
      throw ParserError.unexpectedTokenType(token: token, expected: .identifier)
    }

    _ = try? consume()

    return IdentifierExpression(value: token.value)
  }

  mutating func parseFactor() throws -> (any Expression)? {
    guard let token = peek() else {
      return nil
    }

    switch token.type {
    case .integerLiteral:
      return try parseIntLiteral()
    case .identifier:
      return try parseIdentifier()
    default:
      fatalError("Not implemented")
    }
  }

  mutating func parseTerm() throws -> (any Expression)? {
    guard var left = try parseFactor() else {
      return nil
    }

    while let op = peek(), ["*", "/"].contains(op.value) {
      _ = try? consume()
      guard let right = try parseFactor() else {
        return nil
      }

      left = BinaryOpExpression(left: left, op: op.value, right: right)
    }

    return left
  }

  mutating func parseExpression() throws -> (any Expression)? {
    guard var left = try parseTerm() else {
      return nil
    }

    while let op = peek(), ["+", "-"].contains(op.value) {
      _ = try? consume()
      guard let right = try parseTerm() else {
        return nil
      }

      left = BinaryOpExpression(left: left, op: op.value, right: right)
    }

    return left
  }
}
