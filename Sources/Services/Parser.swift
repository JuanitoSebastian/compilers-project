struct Parser {
  let tokens: [Token]
  var position: Int = 0

  func peek() -> Token? {
    return position < tokens.count ? tokens[position] : nil
  }

  mutating func consume(_ expected: String...) -> Token? {
    guard let token = peek() else {
      return nil
    }

    if expected.count > 0 && !expected.contains(token.value) {
      // TODO: Create a custom error type
      fatalError("Expected \(expected) at \(token.location), got \(token.value)")
    }

    position += 1
    return token
  }

  mutating func parseIntLiteral() -> LiteralExpression<Int>? {
    guard let token = peek() else {
      return nil
    }

    guard token.type == .integerLiteral, let value = Int(token.value) else {
      fatalError("Expected integer literal at \(token.location), got \(token.value)")
    }

    _ = consume()

    return LiteralExpression<Int>(value: value)
  }

  mutating func parseIdentifier() -> IdentifierExpression? {
    guard let token = peek() else {
      return nil
    }

    guard token.type == .identifier else {
      fatalError("Expected identifier at \(token.location), got \(token.value)")
    }

    _ = consume()

    return IdentifierExpression(value: token.value)
  }

  mutating func parseTerm() -> (any Expression)? {
    guard let token = peek() else {
      return nil
    }

    switch token.type {
    case .integerLiteral:
      return parseIntLiteral()
    case .identifier:
      return parseIdentifier()
    default:
      fatalError("Not implemented")
    }
  }

  mutating func parseExpression() -> (any Expression)? {
    guard let left = parseTerm() else {
      return nil
    }

    guard let op = consume("+", "-", "*") else {
      return nil
    }

    guard let right = parseTerm() else {
      return nil
    }

    return BinaryOpExpression(left: left, op: op.value, right: right)
  }
}
