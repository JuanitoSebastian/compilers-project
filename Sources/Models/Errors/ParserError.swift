enum ParserError: Error, Equatable {
  case unexpectedTokenValue(token: Token, expected: [String])
  case unexpectedTokenType(token: Token, expected: TokenType)
  case invalidInputError(token: Token)
}
