enum ParserError: Error {
  case unexpectedTokenValue(token: Token, expected: [String])
  case unexpectedTokenType(token: Token, expected: TokenType)
}
