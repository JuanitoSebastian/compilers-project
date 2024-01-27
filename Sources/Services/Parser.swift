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
      fatalError("Expected \(expected) at \(token.location), got \(token.value)")
    }

    position += 1
    return token
  }

  mutating func parseIntLiteral() -> LiteralExpression<Int>? {
    guard let token = consume() else {
      return nil
    }

    guard token.type == .integerLiteral, let value = Int(token.value) else {
      fatalError("Expected integer literal at \(token.location), got \(token.value)")
    }

    return LiteralExpression<Int>(value: value)
  }

  mutating func parseExpression() -> (any Expression)? {
    guard let left = parseIntLiteral() else {
      return nil
    }

    guard let op = consume("+", "-", "*") else {
      return nil
    }

    guard let right = parseIntLiteral() else {
      return nil
    }

    return BinaryOpExpression(left: left, op: op.value, right: right)
  }
}
