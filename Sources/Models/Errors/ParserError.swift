// TODO: Revisit these. Are all of these necessary? Add location information to all of them.

enum ParserError: Error, Equatable {
  case unexpectedTokenValue(token: Token, expected: [String])
  case unexpectedTokenType(token: Token, expected: [TokenType])
  case noTokenFound(precedingToken: Token?)
  case ifExpressionMissingCondition
  case ifExpressionMissingThenExpression
  case missingSemicolon(token: Token)
  case varDeclarationOutsideBlock(token: Token? = nil)
  case varDeclarationMissingExpression(token: Token? = nil)
  case varDeclarationInvalid(token: Token? = nil)
  case varDeclarationUnsupportedType(token: Token? = nil)
  case whileExpressionMissingCondition
}
