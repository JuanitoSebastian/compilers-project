enum ParserError: Error, Equatable {
  case unexpectedTokenValue(token: Token, expected: [String])
  case unexpectedTokenType(token: Token, expected: [TokenType])
  case noTokenFound(precedingToken: Token)
  case ifExpressionMissingCondition
  case ifExpressionMissingThenExpression
}
