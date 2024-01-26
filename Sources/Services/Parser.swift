struct Parser {
  let tokens: [Token]
  var position: Int = 0

  func peek() -> Token? {
    return position < tokens.count ? tokens[position] : nil
  }

  mutating func consume(_ expected: String?...) -> Token? {
    guard let token = peek() else {
      return nil
    }

    if !expected.contains(token.stringRepresentation) {
      fatalError("Expected \(expected) at \(token.location), got \(token.stringRepresentation)")
    }

    position += 1
    return token
  }

  func parseIntLiteral() -> LiteralExpression<Int>? {
    guard let token = peek() as? IntegerLiteralToken else {
      return nil
    }

    if token.type != .integerLiteral {
      fatalError("Expected integer literal at \(token.location), got \(token.stringRepresentation)")
    }

    return LiteralExpression(value: token.value)
  }

  func parseBinaryOp() -> BinaryOpExpression? {
    guard let left = parseIntLiteral() else {
      return nil
    }

    guard let right = parseIntLiteral() else {
      return nil
    }

    return nil
  }
}
